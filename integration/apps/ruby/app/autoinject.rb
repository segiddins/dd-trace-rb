pid = Process.pid

puts pid

# Do anything with auto injection?
if ENV['DDTRACE_AUTOINJECT'] && !ENV['skip_autoinject']
  if system 'skip_autoinject=true bundle show ddtrace'
    puts "ddtrace already installed..."
    puts "Do nothing"
  else
    puts "ddtrace is not installed..."
    puts "Perform auto-injection..."

    if system 'skip_autoinject=true bundle add ddtrace --require ddtrace/auto_instrument'
      puts "ddtrace added to bundle..."
    else
      puts "Something went wrong when adding ddtrace to bundle... debug here"
    end
  end
end

begin
  require 'ddtrace'
rescue LoadError => e
end
