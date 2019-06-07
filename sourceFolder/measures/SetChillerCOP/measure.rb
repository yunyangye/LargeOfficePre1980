# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class SetChillerCOP < OpenStudio::Ruleset::ModelUserScript

  # human readable name
  def name
    return "Set Chiller COP"
  end

  # human readable description
  def description
    return "This measure aims to change chiller COP."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Change chiller COP."
  end

  #define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # Chiller Thermal Efficiency (default of 3)
    chiller_thermal_efficiency = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("chiller_thermal_efficiency")
    chiller_thermal_efficiency.setDisplayName("Chiller rated COP (more than 0)")
    chiller_thermal_efficiency.setDefaultValue(3)
    args << chiller_thermal_efficiency
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
    chiller_thermal_efficiency = runner.getDoubleArgumentValue("chiller_thermal_efficiency",user_arguments)

    #ruby test to see if efficient is greater than 0
    if chiller_thermal_efficiency < 0 #error on impossible values
      runner.registerError("Chiller COP must be greater than 0. You entered #{chiller_thermal_efficiency}.")
      return false
    end

    #loop through to find water chiller getBoilerHotWaters, to_BoilerHotWater
    model.getChillerElectricEIRs.each do |chiller_water|
      if not chiller_water.to_ChillerElectricEIR.empty?
        water_unit = chiller_water.to_ChillerElectricEIR.get
        unit_name = water_unit.name

        # thermal_efficiency_old = water_unit.nominalThermalEfficiency()
        thermal_efficiency_old = water_unit.referenceCOP()

        #if thermal_efficiency_old.nil?	
        if not thermal_efficiency_old.is_a? Numeric
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was not set.")	
        else
          runner.registerInfo("Initial: The Thermal Efficiency for '#{unit_name}' was #{thermal_efficiency_old}.")
        end
        
        water_unit.setReferenceCOP(chiller_thermal_efficiency)
        runner.registerFinalCondition("Final: The Thermal Efficiency for '#{unit_name}' was #{chiller_thermal_efficiency}.")	
      end
    end

    return true
 
  end #end the run method

end #end the measure

# register the measure to be used by the application
SetChillerCOP.new.registerWithApplication
