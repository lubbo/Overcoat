module Overcoat
  module CoreData
    # Workaround to support both Mantle 1.x and 2.x
    def self.spec(s)
      mantle_version = s.name.split('/')[-1][-1].to_i

      s.default_subspec = 'NSURLConnection', 'NSURLSession'

      s.subspec 'Core' do |ss|
        ss.dependency 'Overcoat/Core'
        ss.frameworks = 'CoreData'
        ss.source_files = 'sources/CoreData/*.{h,m}'
        ss.private_header_files = 'sources/CoreData/*_Internal.h'
        ss.exclude_files = 'sources/CoreData/OVCManagedHTTP{RequestOperation,Session}Manager.{h,m}'
        ss.pod_target_xcconfig = ss.user_target_xcconfig = {
          'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_COREDATA=1',  # Used for shortcuts in umbrella header
        }

        ss.dependency 'Mantle', "~> #{mantle_version}"
        if mantle_version == 2
          ss.dependency 'MTLManagedObjectAdapter', '> 1.0'
        end
      end

      s.subspec 'NSURLConnection' do |ss|
        ss.dependency 'Overcoat/NSURLConnection'
        ss.dependency "Overcoat/CoreData/Mantle#{mantle_version}/Core"
        ss.source_files = 'sources/CoreData/OVCManagedHTTPRequestOperationManager.{h,m}'
      end

      s.subspec 'NSURLSession' do |ss|
        ss.dependency 'Overcoat/NSURLSession'
        ss.dependency "Overcoat/CoreData/Mantle#{mantle_version}/Core"
        ss.source_files = 'sources/CoreData/OVCManagedHTTPSessionManager.{h,m}'
      end
    end
  end
end


# == Main ==============================================================================================================

Pod::Spec.new do |s|
  s.name     = 'Overcoat'
  s.version  = '3.2.0'
  s.cocoapods_version = '>= 0.38'
  s.license  = 'MIT'
  s.summary  = 'Overcoat is a small but powerful library that makes creating REST clients simple and fun.'
  s.homepage = 'https://github.com/overcoat/Overcoat'
  s.authors  = { 'Guillermo Gonzalez' => 'gonzalezreal@icloud.com', 'sodastsai' => 'sodas@icloud.com' }
  s.source   = { :git => 'https://github.com/overcoat/Overcoat.git', :tag => "#{s.version.to_s}" }
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'

  s.default_subspec = 'NSURLConnection', 'NSURLSession'

  # -- Core Subspecs ---------------------------------------------------------------------------------------------------

  s.subspec 'Core' do |ss|
    ss.dependency 'Mantle'
    ss.dependency 'AFNetworking/Serialization'
    ss.source_files = 'sources/Core/*.{h,m}'
    ss.private_header_files = 'sources/Core/*_Internal.h'
    ss.exclude_files = 'sources/Core/OVCHTTP{RequestOperation,Session}Manager.{h,m}'
  end

  s.subspec 'NSURLConnection' do |ss|
    ss.dependency 'Overcoat/Core'
    ss.dependency 'AFNetworking/NSURLConnection'
    ss.source_files = 'sources/Core/OVCHTTPRequestOperationManager.{h,m}'
    ss.pod_target_xcconfig = ss.user_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_URL_CONNECTION=1',  # Used for shortcuts in umbrella header
    }
  end

  s.subspec 'NSURLSession' do |ss|
    ss.dependency 'Overcoat/Core'
    ss.dependency 'AFNetworking/NSURLSession'
    ss.source_files = 'sources/Core/OVCHTTPSessionManager.{h,m}'
    ss.pod_target_xcconfig = ss.user_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_URL_SESSION=1',  # Used for shortcuts in umbrella header
    }
  end

  # -- CoreData Subspecs -----------------------------------------------------------------------------------------------

  s.subspec 'CoreData' do |ss|
    ss.subspec 'Mantle2' do |sss|
      Overcoat::CoreData::spec sss
    end

    ss.subspec 'Mantle1' do |sss|
      Overcoat::CoreData::spec sss
    end

    ss.default_subspec = 'Mantle2'
  end

  # -- Misc Subspecs ---------------------------------------------------------------------------------------------------

  s.subspec 'Social' do |ss|
    ss.dependency 'AFNetworking/Serialization'
    ss.public_header_files = 'sources/Social/*.h'
    ss.source_files = 'sources/Social/*.{h,m}'
    ss.frameworks = 'Accounts', 'Social'
    ss.pod_target_xcconfig = ss.user_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_SOCIAL=1',  # Used for shortcuts in umbrella header
    }
  end

  s.subspec 'PromiseKit' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.9'

    ss.dependency 'PromiseKit/CorePromise', '> 3'  # Swift 2.0 support comes after PromiseKit 3.0
    ss.source_files = 'sources/PromiseKit/PromiseKit+Overcoat.h'
    ss.pod_target_xcconfig = ss.user_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_PROMISE_KIT=1',  # Used for shortcuts in umbrella header
    }
    ss.default_subspec = 'NSURLConnection', 'NSURLSession'

    ss.subspec 'NSURLConnection' do |sss|
      sss.dependency 'Overcoat/NSURLConnection'
      sss.source_files = 'sources/PromiseKit/OVCHTTPRequestOperationManager+PromiseKit.{h,m}'
    end
    ss.subspec 'NSURLSession' do |sss|
      sss.dependency 'Overcoat/NSURLSession'
      sss.source_files = 'sources/PromiseKit/OVCHTTPSessionManager+PromiseKit.{h,m}'
    end
  end

  s.subspec 'ReactiveCocoa' do |ss|
    ss.dependency 'ReactiveCocoa', '~> 2.4'
    ss.source_files = 'sources/ReactiveCocoa/ReactiveCocoa+Overcoat.h'
    ss.pod_target_xcconfig = ss.user_target_xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => 'OVERCOAT_SUPPORT_REACTIVE_COCOA=1',  # Used for shortcuts in umbrella header
    }
    ss.default_subspec = 'NSURLConnection', 'NSURLSession'

    ss.subspec 'NSURLConnection' do |sss|
      sss.dependency 'Overcoat/NSURLConnection'
      sss.source_files = 'sources/ReactiveCocoa/OVCHTTPRequestOperationManager+ReactiveCocoa.{h,m}'
    end
    ss.subspec 'NSURLSession' do |sss|
      sss.dependency 'Overcoat/NSURLSession'
      sss.source_files = 'sources/ReactiveCocoa/OVCHTTPSessionManager+ReactiveCocoa.{h,m}'
    end
  end

end
