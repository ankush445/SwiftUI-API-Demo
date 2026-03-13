import Combine
import Foundation
@MainActor
final class UserViewModel: ObservableObject {

    private let repository: UserRepositoryProtocol

    @Published var users: [User] = []
    @Published var selectedUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func fetchUsers() async {
        isLoading = true

        do {
            users = try await repository.getUsers()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchUser(id: Int) async {
        do {
            selectedUser = try await repository.getUser(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createUser(name: String, email: String) async {

        do {
            let newUser = try await repository.createUser(name: name, email: email)
            users.append(newUser)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateUser(id: Int, name: String, email: String) async {

        do {
            let updatedUser = try await repository.updateUser(id: id, name: name, email: email)

            if let index = users.firstIndex(where: { $0.id == id }) {
                users[index] = updatedUser
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteUser(id: Int) async {

        do {
            try await repository.deleteUser(id: id)
            users.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
