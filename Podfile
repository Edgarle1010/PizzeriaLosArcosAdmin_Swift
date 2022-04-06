platform :ios, '13.0'

target 'PizzeriaLosArcosAdmin' do
  use_frameworks!

  # Pods for PizzeriaLosArcosAdmin

  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Messaging'
  pod 'FirebaseFirestoreSwift', '> 7.0-beta'
  pod 'Firebase/Messaging'
  
  pod 'IQKeyboardManagerSwift', :inhibit_warnings => true
  pod 'ProgressHUD'
  pod 'BonsaiController'
  pod 'RealmSwift', '~>10'
  pod 'SwipeCellKit'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end

end
