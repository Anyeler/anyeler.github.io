
---
layout:     post
title:      使用Cocoapods创建私有podspec
subtitle:   
date:       2017-09-27
author:     Anyeler
header-img: img/post-bg-debug.png
catalog: true
tags:
    - iOS
    - Cocoapods
---

# 使用Cocoapods创建私有podspec
【**简介**】目前公司正在需要封装swift的私有公共库，所以需要了解针对swift进行配置封装。

## 常用 pod 命令
### CocoPods操作
- 添加私有的repo到CocoaPods
  ```ruby
  #pod repo add REPO名 存放podsepc的仓库
  pod repo add liuchungui https://github.com/liuchungui/first.gitpod lib create podTestLibrary
  ```
  
- 添加pod项目到私有specs库
  ```ruby
  #PodRepo是本地Repo名字 后面是podspec名字
  pod repo push PodRepo LogSwift.podspec  
  ```

### Pod项目源代码操作

- 创建Pod项目工程文件
  
  ```ruby
  #pod lib create 项目名
  pod lib create podTestLibrary
  ```
  
- Git库打Tag
  ```ruby
  git tag -m "改动内容" 0.1.0
  git push --tags     #推送tag到远端仓库
  ```

- 创建podspec文件
  ```ruby
  # LogSwift为项目名
  pod spec create LogSwift git@coding.net:boyers/LogSwift.git
  ```


- 编辑podspec文件
  ```ruby

  Pod::Spec.new do |s|
  s.name             = "PodTestLibrary"    #名称
  s.version          = "0.1.0"             #版本号
  s.summary          = "Just Testing."     #简短介绍，下面是详细介绍
  s.description      = <<-DESC
  Testing Private Podspec.
  * Markdown format.
  * Don't worry about the indent, we strip it!
  DESC
  s.homepage         = "https://coding.net/u/boyers/p/podTestLibrary"                           #主页,这里要填写可以访问到的地址，不然验证不通过
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"           #截图
  s.license          = 'MIT'              #开源协议
  s.author           = { "boyers" => "boyers@foxmail.com" }  #作者信息
  s.source           = { :git => "https://coding.net/boyers/podTestLibrary.git", :tag => "0.1.0" }      #项目地址，这里不支持ssh的地址，验证不通过，只支持HTTP和HTTPS，最好使用HTTPS
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'                       #多媒体介绍地址
  s.platform     = :ios, '7.0'            #支持的平台及版本
  s.requires_arc = true                   #是否使用ARC，如果指定具体文件，则具体的问题使用ARC
  s.source_files = 'Pod/Classes/**/*'     #代码源文件地址，**/*表示Classes目录及其子目录下所有文件，如果有多个目录下则用逗号分开，如果需要在项目中分组显示，这里也要做相应的设置
  s.resource_bundles = {
    'PodTestLibrary' => ['Pod/Assets/*.png']
  }                                       #资源文件地址
  s.public_header_files = 'Pod/Classes/**/*.h'   #公开头文件地址
  s.frameworks = 'UIKit'                  #所需的framework，多个用逗号隔开
  s.dependency 'AFNetworking', '~> 2.3'
  #依赖关系，该项目所依赖的其他库，如果有多个需要填写多个s.dependency
  end

  ```

- 验证本地podspec文件可用性
  ```ruby
  # 有引用私有库的时候需要指明私有库
  # pod lib lint --source=https://github.com/CocoaPods/Specs.git,192.168.0.100:Plutoy/Specs.git
  $ pod lib lint
  输出：
  -> PodTestLibrary (0.1.0)
  PodTestLibrary passed validation.
  ```

- 验证远程git仓库podspec文件可用性
  ```ruby
  # 有引用私有库的时候需要指明私有库
  # pod spec lint --source=https://github.com/CocoaPods/Specs.git,192.168.0.100:Plutoy/Specs.git
  $ pod spec lint
  输出：
  -> PodTestLibrary (0.1.0)
  PodTestLibrary passed validation.
  ```

## 参考文档
- AFNetWorking, Alamofire, HandyJson, Sqlite.swift的*.podspec文件
- [wtlucky's Blog](http://blog.wtlucky.com/blog/2015/02/26/create-private-podspec/)
- [布袋男儿](https://huos3203.github.io/2017/02/28/swift/使用Cocoapods创建私有podspec/)
- [刘春桂的博客](https://liuchungui.gitbooks.io/blog/content/cocoapodsmd.html)