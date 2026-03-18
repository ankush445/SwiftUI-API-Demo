import Combine
import Foundation
import FancyToastKit
@MainActor
final class UserViewModel: ObservableObject {
    
    private let repository: UserRepositoryProtocol
    
    @Published var users: [User] = []
    @Published var selectedUser: User?
    @Published var isLoading = false
    @Published var toast: FancyToast?
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchUsers() async {
        isLoading = true
        
        do {
            users = try await repository.getUsers()
        } catch {
            toast = FancyToast(
                type: .error,
                title: "Error",
                message: error.localizedDescription,
                duration: 2.5
            )
        }
        
        isLoading = false
    }
    
    func fetchUser(id: Int) async {
        do {
            selectedUser = try await repository.getUser(id: id)
        } catch {
            toast = FancyToast(
                type: .error,
                title: "Error",
                message: error.localizedDescription,
                duration: 2.5
            )
        }
    }
    
    func createUser(name: String, email: String) async {
        
        do {
            let newUser = try await repository.createUser(name: name, email: email)
            users.append(newUser)
        } catch {
            toast = FancyToast(
                type: .error,
                title: "Error",
                message: error.localizedDescription,
                duration: 2.5
            )
        }
    }
    
    func updateUser(id: Int, name: String, email: String) async {
        
        do {
            let updatedUser = try await repository.updateUser(id: id, name: name, email: email)
            
            if let index = users.firstIndex(where: { $0.id == id }) {
                users[index] = updatedUser
            }
            
        } catch {
            toast = FancyToast(
                type: .error,
                title: "Error",
                message: error.localizedDescription,
                duration: 2.5
            )
        }
    }
    
    func deleteUser(id: Int) async {
        
        do {
            try await repository.deleteUser(id: id)
            users.removeAll { $0.id == id }
        } catch {
            toast = FancyToast(
                type: .error,
                title: "Error",
                message: error.localizedDescription,
                duration: 2.5
            )
        }
    }
}
