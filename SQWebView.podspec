#
# Be sure to run `pod lib lint SQWebView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQWebView'
  s.version          = '0.1.0'
  s.summary          = '统一的WebView组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
封装UIWebView 和 WKWebView组件; 无缝切换使用Webview；
集成了WebJavaScriptBrige组件，方便调用H5的的统一API
解决WKWebViewCookie不同步的问题
                       DESC

  s.homepage         = 'https://github.com/liao3841054/SQWebView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '251180323@qq.com' => '251180323@qq.com' }
  s.source           = { :git => 'https://github.com/liao3841054/SQWebView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SQWebView/**/*'

  s.dependency 'WebViewJavascriptBridge', '~> 6.0.3'

end
