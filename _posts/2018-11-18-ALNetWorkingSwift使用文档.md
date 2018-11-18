---
layout:     post
title:      ALNetWorkingSwift使用文档
subtitle:   介绍自己开发的网络框架的架构和使用
date:       2018-11-18
author:     Anyeler
header-img: img/home-bg-art.jpg
catalog: true
tags:
    - iOS
    - swift
    - HTTP/HTTPS
    - 网络
    - 框架
---


# 前言
这几个月因为由于各种事各种忙，所以都没有写文章。还有一个比较重要的原因就是不知道写哪些比较有质量的文章来供大家阅读，这样说来的话，恰恰是违反了我自己写文章的初心：记录自己日常开发遇到的问题以及解决方案，目的是供自己和他人以后查阅。

闲话不多说，前段时间由于公司需要设计 `swift` 语言编写的**公共库**。所以，我这边除了研究整个公共库的整体设计之外，还重点研究了关于 `swift` 网络框架以及相关第三方库的设计源码和设计思想。


# 框架设计
`ALNetWorkingSwift` 框架是我前段时间研究 [**AFNetworking**](https://github.com/AFNetworking/AFNetworking)、[**Alamofire**](https://github.com/Alamofire/Alamofire)、[**Moya**](https://github.com/Moya/Moya)、[**HandyJSON**](https://github.com/alibaba/HandyJSON) 和 [**ObjectMapper**](https://github.com/tristanhimmelman/ObjectMapper) 等框架，总结提炼出的网络框架。不过相对于 `Moya` 这个框架来说， `ALNetWorkingSwift` 是一个比较轻量级的网络框架。

## 设计初心
其实，编写和设计这个 `ALNetWorkingSwift` 框架为了解决的一个问题就是能够让开发者在 `Swift` 项目中，可以更加快速方便的发起 **HTTP/HTTPS** 请求，并且能够直接拿到已经映射好的 `Model` 模型，自动打印出接收到的数据。

## 依赖关系
为了解决开发者能够直接能拿到网络请求返回的**数据模型**，以及能够方便的发起网络请求。这边选用的是对 `Alamofire` 和 `HandyJSON` 进行二次封装。其中， `Alamofire` 网络框架是发起网络请求，`HandyJSON` 则是用于映射生成 `Model`。

`ALNetWorkingSwift` 框架的依赖关系以及需要达到的效果图如下：

![**依赖关系图**](https://alpics-1251916310.file.myqcloud.com/article/2018-11-15-al_net_%20dependencies%2023.44.54.jpg)

## 架构图
`ALNetWorkingSwift` 框架，其中有一个 `Core` 模块，开发者可用直接使用 `cocoapods` 只依赖 `Core` 模块，整体的架构如下图所示：

![**ALNetWorkingSwift 架构图**](https://alpics-1251916310.file.myqcloud.com/article/2018-11-18-al_net_framework.jpg)

如上图所示，开发者主要是调用 `ALNetHTTPRequestOperationManager` 类进行网络请求，其中可以通过 `ALNetHTTPCommonConfig` 进行基本配置，最后请求后回调的结构体是遵守 `ALNetHTTPResponse` 协议的结构体。结构体里面定义的 `data` 字段是一个泛型用于业务中使用。所以，可以根据不同的项目依赖 `Core` 模块，在项目中定制适合自己的网络请求模块。

在架构图中，网络请求是基于 `Core` 模块进行发送请求和解析数据的。目前，这个模块封装的比较轻量级，灵活性也比较高。接下来具体介绍 `Core` 模块的架构，如下图所示：

![**Core模块架构图**](https://alpics-1251916310.file.myqcloud.com/article/2018-11-18-al_net_core.jpg)


# 基本使用说明
您可以调用该方法来初始化一个通用的网络请求:
```swift
ALHTTPRequestOperationManager.default.requestBase(httpMethod: .get, url: "https://www.baidu.com", urlEncoding: TURLEncoding.default, parameter: nil) { (response) in        
    switch response.result {
    case .success(let res):
        print(res)
    case .failure(let err):
        print(err)
    }
}
```

您也可以调用以下方法来上传数据:

```swift
ALHTTPRequestOperationManager.default.uploadBase(url: "https://www.baidu.com", multipartFormData: { (formData) in
    // The assembly to upload data
}) { (result) in
    switch result {
    case .success(let request, let streamingFromDisk, let streamFileURL):
        print(request)
        print(streamingFromDisk)
        print(streamFileURL ?? "")
    case .failure(let err):
        print(err)
    }
}
```

此处返回的成功或失败的判定是相对于服务器而言的，而不是业务相关的状态码。也就是说网络请求收到的*不合法*的数据或者服务器异常的情况，会判定失败。

# 高级用法
您还可以重新封装这两种方法以满足业务需求。

为了符合 `ALCommonConfigProtocol`，结构体需要实现一些属性和方法：

```swift
public struct HTTPConfig: ALCommonConfigProtocol {
    
    public var kHttpUserAgent: String = ""
    
    init() {
        
    }
    
    public func getHeader(dictHeader: [String: String]? = nil) -> [String: String] {
        var header: [String:String] = [String: String]()
        if dictHeader != nil {
            header.merge(dictHeader!) { (_, new) in new }
        }
        return header
    }
    
    public func getContentType(contentType: Set<String>? = nil) -> Set<String> {
        var content: Set<String> = Set<String>()
        contentType?.forEach({ (ele) in
            content.insert(ele)
        })
        return content
    }
}
```

然后,调用这个方法：

```swift
ALHTTPRequestOperationManager.default.httpConfig = HTTPConfig()
```

# 框架相关链接

[**ALNetWorkingSwift**](https://github.com/Anyeler/ALNetWorkingSwift)