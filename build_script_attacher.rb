require 'xcodeproj'
require 'fileutils'

# Path to the source script
source_script_path = '/Users/becca/StudioProjects/flutter/Work/Adire/flutter_genesis_cli/build_script_gen.sh'

project = Xcodeproj::Project.open "./Runner.xcodeproj"

for target in project.targets 
    puts "Target -> " + target.name

    @scriptName = "Firebase json run script"
    phase = target.shell_script_build_phases().find {|item| item.name ==  @scriptName }
    if (phase.nil?)
        puts "Creating script '#{@scriptName}'"
        phase = target.new_shell_script_build_phase( @scriptName )
        script_content = File.read(source_script_path)
        phase.shell_script = script_content
    else
        puts "'#{@scriptName}' already exist" 
        script_content = File.read(source_script_path)
        phase.shell_script = script_content
    end
end

project.save() 