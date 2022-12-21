//
//  DIContainer.swift
//  MarvelApp
//
//  Created by German Azcona on 12/15/22.
//

import Foundation

class DIContainer: ObservableObject {
    func register<Dependency>(_ dependencyType: Dependency.Type, factory: @escaping (DIContainer) -> Dependency) {
        fatalError("unimplemented")
    }
    func resolve<Dependency>(_ dependencyType: Dependency.Type = Dependency.self) -> Dependency {
        fatalError("unimplemented")
    }
}

import Swinject

class SwinjectDIContainer: DIContainer {
    private let container = Swinject.Container()

    override func resolve<Dependency>(_ dependencyType: Dependency.Type) -> Dependency {
        guard let dependency = container.resolve(dependencyType) else {
            preconditionFailure("Can't resolve dependency of type: \(dependencyType)")
        }
        return dependency
    }
    override func register<Dependency>(_ dependencyType: Dependency.Type, factory: @escaping (DIContainer) -> Dependency) {
        container.register(dependencyType) { [weak self] resolver in
            factory(self!)
        }.inObjectScope(.container)
    }
}

import APIService
import MarvelService

extension DIContainer {

    func registerLiveDependencies() {
        register(APIService.self) { container in
            URLSessionAPIService()
        }
        register(MarvelService.self) { container in
            MarvelServiceLive(
                apiService: container.resolve(),
                apiKey: "4420276507578e660b38c6a7eda4bf90",
                coreDataService: container.resolve()
            )
        }
    }
}
