return if ENV['DD_TRACE_SKIP_LIB_INJECTION'] == 'true'

begin
  require 'open3'
  require 'bundler'
  require 'shellwords'

  failure_prefix = 'Datadog lib injection failed:'
  support_message = 'For help solving this issue, please contact Datadog support at https://docs.datadoghq.com/help/.'

  unless Bundler::SharedHelpers.in_bundle?
    STDOUT.puts '[ddtrace] Not in bundle... skipping host injection' if ENV['DD_TRACE_DEBUG'] == 'true'
    return
  end

  if Bundler.frozen_bundle?
    STDERR.puts "[ddtrace] #{failure_prefix} Cannot inject with frozen Gemfile, run `bundle config unset deployment` to allow lib injection. To learn more about bundler deployment, check https://bundler.io/guides/deploying.html#deploying-your-application. #{support_message}"
    return
  end

  _, status = Open3.capture2e({'DD_TRACE_SKIP_LIB_INJECTION' => 'true'}, 'bundle show ddtrace')

  if status.success?
    STDOUT.puts '[ddtrace] ddtrace already installed... skipping host injection' if ENV['DD_TRACE_DEBUG'] == 'true'
    return
  end

  bundle_add_ddtrace_cmd =
    'bundle add ddtrace --require ddtrace/auto_instrument --skip-install'

  STDOUT.puts "[ddtrace] Performing lib injection with `#{bundle_add_ddtrace_cmd}`" if ENV['DD_TRACE_DEBUG'] == 'true'

  gemfile   = Bundler::SharedHelpers.default_gemfile
  lockfile  = Bundler::SharedHelpers.default_lockfile

  datadog_gemfile  = gemfile.dirname  + "datadog-Gemfile"
  datadog_lockfile = lockfile.dirname + "datadog-Gemfile.lock"

  require 'fileutils'

  begin
    # Copies for trial
    FileUtils.cp gemfile, datadog_gemfile
    FileUtils.cp lockfile, datadog_lockfile

    output, status = Open3.capture2e(
      { 'DD_TRACE_SKIP_LIB_INJECTION' => 'true', 'BUNDLE_GEMFILE' => datadog_gemfile.to_s },
      bundle_add_ddtrace_cmd
    )

    if status.success?
      STDOUT.puts '[ddtrace] Datadog lib injection successfully added ddtrace to the application.'

      FileUtils.cp datadog_gemfile, gemfile
      FileUtils.cp datadog_lockfile, lockfile
    else
      STDERR.puts "[ddtrace] #{failure_prefix} Unable to add ddtrace. Error output:\n#{output.split("\n").map {|l| "[ddtrace] #{l}"}.join("\n")}\n#{support_message}"
    end
  ensure
    # Remove the copies
    FileUtils.rm datadog_gemfile
    FileUtils.rm datadog_lockfile
  end
rescue Exception => e
  STDERR.puts "[ddtrace] #{failure_prefix} #{e.class.name} #{e.message}\nBacktrace: #{e.backtrace.join("\n")}\n#{support_message}"
end
