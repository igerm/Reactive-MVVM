import CoreData

extension CharacterMO {

    var remote: CharacterRemote? {
        get {
            guard let data = data else { return nil }
            return try? JSONDecoder.marvel.decode(CharacterRemote.self, from: data)
        }
        set {
            guard let newValue = newValue else {
                return
            }
            data = try? JSONEncoder.marvel.encode(newValue)
            name = newValue.name
        }
    }

    var domain: Character {
        get throws {

            guard let remote = remote else { throw DomainModelError.remoteModelMissing }

            return Character(
                id: id,
                name: remote.name,
                characterDescription: remote.characterDescription,
                modified: remote.modified,
                stories: remote.stories,
                events: remote.events,
                thumbnail: remote.thumbnail,
                isFavorite: isFavorite
            )
        }
    }
}
