Pod::Spec.new do |s|
    s.name             = "MOReactor"
    s.module_name      = 'Reactor'
    s.version          = "0.9"
    s.summary          = "Powering your RAC architecture"
    s.description      = <<-EOS
                         Reactor provides a Model layer with minimum configuration.
                         EOS

    s.homepage         = "https://github.com/MailOnline/Reactor"
    s.license          = "MIT"
    s.author           = "MailOnline"
    s.social_media_url = "https://twitter.com/MailOnline"
    s.source           = { :git => "https://github.com/MailOnline/Reactor.git", :tag => s.version.to_s }

    s.ios.deployment_target = "8.0"
    s.dependency 'ReactiveCocoa', '~> 4.0.1'
    s.source_files  = "Reactor/**/*"
end
