import Combine
import XCTest
@testable import MarvelService

final class DecodingTests: XCTestCase {

    var cancellable: AnyCancellable?

    func testResponseParsing() throws {

        let jsonData = Files.stringsResponseJson.data
        let response = try JSONDecoder.marvel.decode(Response<String>.self, from: jsonData)

        let expectedResponse = Response<String>(
            code: 200,
            status: "Ok",
            copyright: "© 2022 MARVEL",
            attributionText: "Data provided by Marvel. © 2022 MARVEL",
            attributionHTML: "<a href=\"http://marvel.com\">Data provided by Marvel. © 2022 MARVEL</a>",
            etag: "185244667870d001e7fb64eb565b79f51f9b6f8b",
            data: .init(
                offset: 0,
                limit: 20,
                total: 1,
                count: 1,
                results: [
                    "result 1",
                    "result 2"
                ]
            )
        )

        XCTAssertEqual(response, expectedResponse)
    }

    func testCharacterParsing() throws {

        let jsonData = Files.characterJson.data
        let character = try JSONDecoder.marvel.decode(CharacterRemote.self, from: jsonData)

        XCTAssertEqual(character.id, 1009351)
        XCTAssertEqual(character.name, "Hulk")
        XCTAssertEqual(character.characterDescription, "Caught in a gamma bomb explosion while trying to save the life of a teenager, Dr. Bruce Banner was transformed into the incredibly powerful creature called the Hulk. An all too often misunderstood hero, the angrier the Hulk gets, the stronger the Hulk gets.")
        XCTAssertEqual(character.modified, DateFormatter.marvel.date(from: "2020-07-21T10:35:15-0400")!)
        XCTAssertEqual(character.thumbnail, .init(
            path: "http://i.annihil.us/u/prod/marvel/i/mg/5/a0/538615ca33ab0",
            fileExtension: "jpg"
        ))
        XCTAssertEqual(character.resourceURI, "http://gateway.marvel.com/v1/public/characters/1009351")
        XCTAssertEqual(character.comics, .init(
            available: 1729,
            returned: 2,
            collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/comics",
            items: [
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/comics/41112",
                    name: "5 Ronin (Hardcover)"
                ),
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/comics/36365",
                    name: "5 Ronin (2010) #2"
                )
            ]
        ))
        XCTAssertEqual(character.series, .init(
            available: 511,
            returned: 2,
            collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/series",
            items: [
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/series/15276",
                    name: "5 Ronin (2011)"
                ),
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/series/12429",
                    name: "5 Ronin (2010)"
                )
            ]
        ))
        XCTAssertEqual(character.stories, .init(
            available: 2619,
            returned: 2,
            collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/stories",
            items: [
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/stories/702",
                    name: "INCREDIBLE HULK (1999) #62",
                    type: "cover"
                ),
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/stories/703",
                    name: "Interior #703",
                    type: "interiorStory"
                )
            ]
        ))
        XCTAssertEqual(character.events, .init(
            available: 26,
            returned: 2,
            collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/events",
            items: [
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/events/116",
                    name: "Acts of Vengeance!"
                ),
                .init(
                    resourceURI: "http://gateway.marvel.com/v1/public/events/303",
                    name: "Age of X"
                )
            ]
        ))
        XCTAssertEqual(character.urls, [
            .init(
                type: "detail",
                url: "http://marvel.com/characters/25/hulk?utm_campaign=apiRef&utm_source=4420276507578e660b38c6a7eda4bf90"
            ),
            .init(
                type: "wiki",
                url: "http://marvel.com/universe/Hulk_(Bruce_Banner)?utm_campaign=apiRef&utm_source=4420276507578e660b38c6a7eda4bf90"
            )
        ])
    }

    func testCharacterEquality() throws {

        let jsonData = Files.characterJson.data
        let character = try JSONDecoder.marvel.decode(CharacterRemote.self, from: jsonData)

        let expectedCharacter = CharacterRemote(
            id: 1009351,
            name: "Hulk",
            characterDescription: "Caught in a gamma bomb explosion while trying to save the life of a teenager, Dr. Bruce Banner was transformed into the incredibly powerful creature called the Hulk. An all too often misunderstood hero, the angrier the Hulk gets, the stronger the Hulk gets.",
            resourceURI: "http://gateway.marvel.com/v1/public/characters/1009351",
            modified: DateFormatter.marvel.date(from: "2020-07-21T10:35:15-0400")!,
            urls: [
                .init(
                    type: "detail",
                    url: "http://marvel.com/characters/25/hulk?utm_campaign=apiRef&utm_source=4420276507578e660b38c6a7eda4bf90"
                ),
                .init(
                    type: "wiki",
                    url: "http://marvel.com/universe/Hulk_(Bruce_Banner)?utm_campaign=apiRef&utm_source=4420276507578e660b38c6a7eda4bf90"
                )
            ],
            thumbnail: .init(
                path: "http://i.annihil.us/u/prod/marvel/i/mg/5/a0/538615ca33ab0",
                fileExtension: "jpg"
            ),
            comics: .init(
                available: 1729,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/comics",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/comics/41112",
                        name: "5 Ronin (Hardcover)"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/comics/36365",
                        name: "5 Ronin (2010) #2"
                    )
                ]
            ),
            stories: .init(
                available: 2619,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/stories",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/702",
                        name: "INCREDIBLE HULK (1999) #62",
                        type: "cover"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/stories/703",
                        name: "Interior #703",
                        type: "interiorStory"
                    )
                ]
            ),
            events: .init(
                available: 26,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/events",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/116",
                        name: "Acts of Vengeance!"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/events/303",
                        name: "Age of X"
                    )
                ]
            ),
            series: .init(
                available: 511,
                returned: 2,
                collectionURI: "http://gateway.marvel.com/v1/public/characters/1009351/series",
                items: [
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/series/15276",
                        name: "5 Ronin (2011)"
                    ),
                    .init(
                        resourceURI: "http://gateway.marvel.com/v1/public/series/12429",
                        name: "5 Ronin (2010)"
                    )
                ]
            )
        )
        XCTAssertEqual(character, expectedCharacter)
    }

    func testFullCharacterResponseParsing() throws {

        let data = Files.charactersResponseJson.data
        let response = try JSONDecoder.marvel.decode(Response<CharacterRemote>.self, from: data)

        XCTAssert(response.data.results.first?.name == "Hulk")

    }
}
