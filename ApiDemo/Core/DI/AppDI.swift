//
//  AppDI.swift
//  ApiDemo
//
//  Created by ios-22 on 17/04/26.
//


final class AppDI {
    static let shared = AppDI()
    
    private init() {}
    
    lazy var tokenStorage: TokenStorage = KeychainTokenStorage()
    
    lazy var networkService = NetworkService(
        tokenStorage: tokenStorage,
        authService: AuthService(tokenStorage: tokenStorage)
    )
    
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository(
        networkService: networkService
    )
    
    lazy var postRepository: PostRepositoryProtocol = PostRepository(
        networkService: networkService
    )
    lazy var settingRepository: SettingRepositoryProtocol = SettingRepository(
        networkService: networkService
    )
    lazy var friendRepository: FriendRepositoryProtocol = FriendRepository(
        networkService: networkService
    )
    lazy var profileRepository: ProfileRepositaryProtocol = ProfileRepositary(
        networkService: networkService
    )
    lazy var followersRepository: FollowersRepositoryProtocol = FollowersRepository(
        networkService: networkService
    )
}
