# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'XWorkerBee' do

pod 'Toast-Swift', '~> 4.0.0'
pod 'Alamofire', '~> 4.7'
pod 'SwiftyJSON'
pod 'DatePickerDialog'
pod 'DropDown'
pod 'OneSignal', '>= 2.6.2', '< 3.0'
pod 'BadgeSwift', '~> 7.0'
pod 'MonthYearPicker'
pod 'Firebase/Core'
pod 'SnapKit'
pod 'SwiftKeychainWrapper'


  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for XWorkerBee
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'No'
      end
    end
  end
  target 'XWorkerBeeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'XWorkerBeeUITests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'OneSignalNotificationServiceExtension' do
      pod 'OneSignal', '>= 2.6.2', '< 3.0'
  end

end



