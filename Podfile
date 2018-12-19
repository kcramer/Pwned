platform :ios, '11.0'

target 'Pwned' do
  use_frameworks!

  plugin 'cocoapods-acknowledgements', :settings_bundle => true

  # Pods
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'RxDataSources', '~> 3.0'
  pod 'RxFlow'
  pod 'Reusable'
  pod 'RxFeedback'
  pod 'Promises'
  pod 'HIBPKit', :git => 'git@github.com:kcramer/HIBPKit.git'
  pod 'ComposableCacheKit', :git => 'git@github.com:kcramer/ComposableCacheKit.git'

  target 'PwnedTests' do
    inherit! :search_paths
    pod 'RxTest'
  end

  target 'PwnedUITests' do
    inherit! :search_paths
  end
end

