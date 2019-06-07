# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class SetBoilerThermalEfficiency < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "Set Boiler Thermal Efficiency"
  end

  # human readable description
  def description
    return "This measure aims to change boiler thermal efficiency."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Change boiler thermal efficiency."
  end

  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # Chiller Thermal Efficiency (default of 3)
    boiler_thermal_efficiency = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("boiler_thermal_efficiency")
    boiler_thermal_efficiency.setDisplayName("Boiler thermal efficiency (0,1)")
    boiler_thermal_efficiency.setDefaultValue(0.8)
    args << boiler_thermal_efficiency
    return args
  end #end the arguments method


  #define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    #use the built-in error checking 
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # #assign the user inputs to variables
    boiler_thermal_efficiency = runner.getDoubleArgumentValue("boiler_thermal_efficiency",user_arguments)

    #ruby test to see if efficient is greater than 0 and smaller than 1
    if boiler_thermal_efficiency < 0 or boiler_thermal_efficiency > 1  #error on impossible values
      runner.registerError("Boiler thermal efficiency must be greater than 0 and smaller than 1. You entered #{boiler_thermal_efficiency}.")
      return false
    end

    #loop through to find water chiller getBoilerHotWaters, to_BoilerHotWater
    model.getBoilerHotWaters.each do |hot_water|
      if not hot_water.to_BoilerHotWater.empty?

        water_unit = hot_water.to_BoilerHotWater.get
        unit_name = water_unit.name

        thermal_efficiency_old = water_unit.nominalThermalEfficiency()

        #if thermal_efficiency_old.nil?	
        if not thermal_efficiency_old.is_a? Numeric
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was not set.")	
        else
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was #{thermal_efficiency_old}.")
        end
        
        water_unit.	setNominalThermalEfficiency(boiler_thermal_efficiency)
        runner.registerInfo("Final: The Thermal Efficiency for '#{unit_name}' was #{boiler_thermal_efficiency}.")	
      end
    end
	
    model.getBoilerSteams.each do |steam|
      if not steam.to_BoilerSteam.empty?

        water_unit = steam.to_BoilerSteam.get
        unit_name = water_unit.name

        thermal_efficiency_old = water_unit.theoreticalEfficiency()

        #if thermal_efficiency_old.nil?	
        if not thermal_efficiency_old.is_a? Numeric
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was not set.")	
        else
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was #{thermal_efficiency_old}.")
        end
        
        water_unit.setTheoreticalEfficiency(boiler_thermal_efficiency)
        runner.registerInfo("Final: The Thermal Efficiency for '#{unit_name}' was #{boiler_thermal_efficiency}.")	
      end
    end	

    return true
 
  end #end the run method

end #end the measure

# register the measure to be used by the application
SetBoilerThermalEfficiency.new.registerWithApplication