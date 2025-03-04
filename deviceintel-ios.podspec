Pod::Spec.new do |spec|
  spec.name             = 'deviceintel-ios'
  spec.version          = '1.0.5'
  
  spec.summary          = 'Identify and prevent fraudulent activity accurately and immediately.'
  spec.description      = 'Device Fingerprinting helps you understand your user’s unique harware with their device data & processes them in backend to generate a fingerprint id.'
  
  spec.homepage         = 'https://www.bureau.id/products/bureau-device-intelligence-behaviorial-biometrics'
  spec.license = 'MIT'
  spec.authors          = {'Bureau-Inc' => 'techops@bureau.id'}
  spec.ios.deployment_target = "12.0"

  spec.source           = { :git => 'https://github.com/Bureau-Inc/deviceintel-ios-sdk.git', :tag => spec.version.to_s }
  
  spec.vendored_frameworks = '**/*.xcframework'
  spec.swift_version = '5.0'
  
  spec.dependency 'Sentry', '8.36.0'
  
end
