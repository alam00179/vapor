import Async
import JunkDrawer
import HTTP
import Foundation
import Service

/// Representable as content in an HTTP message.
public protocol Content: Codable, ResponseCodable, RequestCodable {
    /// The default media type to use when _encoding_ this
    /// content. This can be overridden at the encode call.
    static var defaultMediaType: MediaType { get }
}

extension Content {
    /// See Content.defaultMediaType
    public static var defaultMediaType: MediaType {
        return .json
    }

    /// See RequestEncodable.encode
    public func encode(to req: inout Request) throws -> Signal {
        try req.content.encode(self)
        return .done
    }

    /// See ResponseEncodable.encode
    public func encode(to res: inout Response, for req: Request) throws -> Signal {
        try res.content.encode(self)
        return .done
    }

    /// See RequestDecodable.decode
    public static func decode(from req: Request) throws -> Future<Self> {
        let content = try req.content.decode(Self.self)
        return Future(content)
    }

    /// See ResponseDecodable.decode
    public static func decode(from res: Response, for req: Request) throws -> Future<Self> {
        let content = try res.content.decode(Self.self)
        return Future(content)
    }
}

// MARK: Default Conformance

extension String: Content {
    /// See Content.defaultMediaType
    public static var defaultMediaType: MediaType {
        return .plainText
    }
}

extension Int: Content {
    /// See Content.defaultMediaType
    public static var defaultMediaType: MediaType {
        return .plainText
    }
}

extension Array: Content {
    /// See Content.defaultMediaType
    public static var defaultMediaType: MediaType {
        return .json
    }
}

extension Request {
    public func makeResponse() -> Response {
        return Response(using: superContainer)
    }
}

extension Response {
    public func makeRequest() -> Request {
        return Request(using: superContainer)
    }
}

