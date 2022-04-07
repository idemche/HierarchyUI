#
# Be sure to run `pod lib lint HierarchyUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HierarchyUI'
  s.version          = '0.1.0'
  s.summary          = 'Implementation of declarative UIKit application navigation for SwiftUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  SwiftUI is a declarative UI layouting framework.
  HierarchyUI is a declarative Navigation construction framework.

  As Apple states in its official documentation:
  SwiftUI uses a declarative syntax, so you can simply state what your user interface should do.
  For example, you can write that you want a list of items consisting of text fields,
  then describe alignment, font, and color for each field.
  Your code is simpler and easier to read than ever before, saving you time and maintenance.

  SwiftUI's implementation implies that Navigation is embedded into UI layout, within NavigationLink.
  That creates some limitation in terms of different architectures which tend to separate UI from business
  and navigation logic.

  HierarchyUI provides a way to create a readable and simple way to create a declarative Navigation structure
  separately, without mixing it with UI.
  DESC

  s.homepage         = 'https://github.com/idemche/HierarchyUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'idemche' => 'idemche@gmail.com' }
  s.source           = { :git => 'https://github.com/idemche/HierarchyUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '13.0'

  s.source_files = 'HierarchyUI/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HierarchyUI' => ['HierarchyUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
