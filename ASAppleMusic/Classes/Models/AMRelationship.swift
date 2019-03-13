//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 Relationship object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/relationship)
 */
public class AMRelationship: Decodable {

    public class Album: AMRelationship {

        /// (Required) The data for the album included in the relationship.
        public var data: [AMAlbum] = []

    }

    public class Artist: AMRelationship {

        /// (Required) The data for the artist included in the relationship.
        public var data: [AMArtist] = []

    }

    public class Curator: AMRelationship {

        /// (Required) The data for the curator included in the relationship.
        public var data: [AMCurator] = []

    }

    public class Genre: AMRelationship {

        /// (Required) The data for the genre included in the relationship.
        public var data: [AMGenre] = []

    }

    public class MusicVideo: AMRelationship {

        /// (Required) The data for the music video included in the relationship.
        public var data: [AMMusicVideo] = []

    }

    public class Playlist: AMRelationship {

        /// (Required) The data for the playlist included in the relationship.
        public var data: [AMPlaylist] = []

    }

    public class Station: AMRelationship {

        /// (Required) The data for the station included in the relationship.
        public var data: AMStation = AMStation()

    }

    public class Track: AMRelationship {

        /// (Required) The data for the track included in the relationship.
        public var data: [AMTrack] = []

    }

    public class LibraryAlbum: AMRelationship {

        /// (Required) The data for the library album included in the relationship.
        public var data: [AMLibraryAlbum] = []

    }

    public class LibraryArtist: AMRelationship {

        /// (Required) The data for the library artist included in the relationship.
        public var data: [AMLibraryArtist] = []

    }

    public class LibraryMusicVideo: AMRelationship {

        /// (Required) The data for the library music video included in the relationship.
        public var data: [AMLibraryMusicVideo] = []

    }

    public class LibraryPlaylist: AMRelationship {

        /// (Required) The data for the library playlist included in the relationship.
        public var data: [AMLibraryPlaylist] = []

    }

    public class LibrarySong: AMRelationship {

        /// (Required) The data for the library song included in the relationship.
        public var data: [AMLibrarySong] = []

    }

    public class LibraryTrack: AMRelationship {

        /// (Required) The data for the library track included in the relationship.
        public var data: [AMLibraryTrack] = []

    }

    /// A URL subpath that fetches the resource as the primary object. This member is only present in responses.
    public var href: String?

    /// Link to the next page of resources in the relationship. Contains the offset query parameter that specifies the next page.
    public var next: String?

}
