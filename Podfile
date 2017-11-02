#use_frameworks!

target :'FruitMix' do 

platform :ios,’8.0’
pod 'AFNetworking', '~> 3.1.0'
pod 'pop'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|
            
            config.build_settings['ENABLE_BITCODE'] = 'NO'
            
        end
        
    end
    
end
