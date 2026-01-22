import Foundation

/// Sample data for the app
struct SampleData {

    // MARK: - Sites
    static let sites: [Site] = [
        gizaPyramids,
        luxorTemple,
        valleyOfKings,
        karnakTemple,
        abuSimbel
    ]

    // MARK: - Giza Pyramids Complex
    static let gizaPyramids = Site(
        id: "giza",
        name: "Pyramids of Giza",
        arabicName: "أهرامات الجيزة",
        era: .oldKingdom,
        tourismType: .pharaonic,
        placeType: .pyramid,
        city: .giza,
        shortDescription: "The last surviving wonder of the ancient world.",
        coordinates: Coordinates(latitude: 29.9792, longitude: 31.1342),
        imageNames: ["giza_1", "giza_2", "giza_3"],
        subLocations: [
            // Great Pyramid of Khufu
            SubLocation(
                id: "great_pyramid",
                name: "Great Pyramid of Khufu",
                arabicName: "هرم خوفو الأكبر",
                shortDescription: "The largest and oldest of the three pyramids",
                imageName: "khufu_pyramid",
                storyCards: [
                    StoryCard(id: "khufu_1", type: .intro, imageName: "khufu_main", content: "Standing 481 feet tall, the Great Pyramid was the tallest structure on Earth for over 3,800 years.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "khufu_2", type: .story, imageName: "khufu_build", content: "Built around 2560 BCE for Pharaoh Khufu. It took roughly 20 years and 100,000 workers to complete.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "khufu_3", type: .fact, imageName: nil, content: nil, funFact: "The pyramid contains about 2.3 million stone blocks, each weighing 2.5 tons on average!", quizQuestion: nil),
                    StoryCard(id: "khufu_4", type: .quiz, imageName: nil, content: nil, funFact: nil, quizQuestion: QuizQuestion(
                        id: "q_khufu_1",
                        question: "Who was the Great Pyramid built for?",
                        options: ["Pharaoh Khufu", "Pharaoh Tutankhamun", "Cleopatra", "Ramesses II"],
                        correctAnswerIndex: 0,
                        explanation: "The Great Pyramid was built as a tomb for Pharaoh Khufu (also known as Cheops) of the Fourth Dynasty.",
                        funFact: nil
                    )),
                    StoryCard(id: "khufu_5", type: .story, imageName: "khufu_interior", content: "Inside are three chambers: the King's Chamber with a granite sarcophagus, the Queen's Chamber, and an unfinished underground chamber.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "khufu_6", type: .fact, imageName: nil, content: nil, funFact: "The four sides of the pyramid are aligned almost perfectly with the four cardinal directions!", quizQuestion: nil)
                ]
            ),
            // The Sphinx
            SubLocation(
                id: "sphinx",
                name: "The Great Sphinx",
                arabicName: "أبو الهول",
                shortDescription: "The mysterious guardian with a lion's body and human head",
                imageName: "sphinx",
                storyCards: [
                    StoryCard(id: "sphinx_1", type: .intro, imageName: "sphinx_main", content: "The Great Sphinx is the oldest and largest monolith statue in the world, carved from a single limestone bedrock.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "sphinx_2", type: .story, imageName: "sphinx_face", content: "Standing 66 feet high and 240 feet long, the Sphinx has the body of a lion and the face believed to be of Pharaoh Khafre.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "sphinx_3", type: .fact, imageName: nil, content: nil, funFact: "The Sphinx's nose is missing! Contrary to legend, it wasn't shot off by Napoleon's soldiers.", quizQuestion: nil),
                    StoryCard(id: "sphinx_4", type: .quiz, imageName: nil, content: nil, funFact: nil, quizQuestion: QuizQuestion(
                        id: "q_sphinx_1",
                        question: "What does 'Abu al-Hol' (Arabic name) mean?",
                        options: ["Father of Terror", "Guardian of the Dead", "Sun God", "Stone Lion"],
                        correctAnswerIndex: 0,
                        explanation: "The Arabic name 'Abu al-Hol' translates to 'Father of Terror' or 'Father of Dread'.",
                        funFact: nil
                    ))
                ]
            ),
            // Pyramid of Khafre
            SubLocation(
                id: "khafre_pyramid",
                name: "Pyramid of Khafre",
                arabicName: "هرم خفرع",
                shortDescription: "The second-largest pyramid, built for Khufu's son",
                imageName: "khafre",
                storyCards: [
                    StoryCard(id: "khafre_1", type: .intro, imageName: "khafre_main", content: "Though slightly smaller than the Great Pyramid, Khafre's pyramid appears taller because it's built on higher ground.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "khafre_2", type: .story, imageName: "khafre_cap", content: "It's the only pyramid that still has some of its original white limestone casing at the top, giving us a glimpse of how all pyramids once gleamed.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "khafre_3", type: .fact, imageName: nil, content: nil, funFact: "The pyramids were originally covered in polished white limestone that would have shone brilliantly in the sun!", quizQuestion: nil)
                ]
            ),
            // Solar Boat Museum
            SubLocation(
                id: "solar_boat",
                name: "Solar Boat Museum",
                arabicName: "متحف مركب الشمس",
                shortDescription: "Houses a reconstructed ancient boat buried near the Great Pyramid",
                imageName: "solar_boat",
                storyCards: [
                    StoryCard(id: "boat_1", type: .intro, imageName: "boat_main", content: "In 1954, archaeologists discovered a 4,600-year-old boat buried in a pit beside the Great Pyramid.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "boat_2", type: .story, imageName: "boat_pieces", content: "The boat was found in 1,224 pieces. It took 14 years to carefully reassemble this ancient vessel.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "boat_3", type: .fact, imageName: nil, content: nil, funFact: "At 143 feet long, it's one of the oldest and largest ancient vessels ever found!", quizQuestion: nil),
                    StoryCard(id: "boat_4", type: .quiz, imageName: nil, content: nil, funFact: nil, quizQuestion: QuizQuestion(
                        id: "q_boat_1",
                        question: "What was the solar boat's purpose?",
                        options: ["Carry the pharaoh's soul to the afterlife", "Fishing on the Nile", "Military transport", "Trade with other kingdoms"],
                        correctAnswerIndex: 0,
                        explanation: "The solar boat was meant to carry the pharaoh's soul across the heavens with the sun god Ra.",
                        funFact: nil
                    ))
                ]
            )
        ],
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning (8-10 AM) or late afternoon",
            tips: [
                "Bring plenty of water and sun protection",
                "Hire an official guide at the entrance",
                "The interior of the Great Pyramid is hot and cramped",
                "Visit the Solar Boat Museum"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Pyramid", arabic: "هرم", pronunciation: "haram"),
                ArabicPhrase(english: "How much?", arabic: "بكام؟", pronunciation: "bekam?"),
                ArabicPhrase(english: "Thank you", arabic: "شكراً", pronunciation: "shukran")
            ]
        ),
        isUnlocked: true
    )

    // MARK: - Luxor Temple
    static let luxorTemple = Site(
        id: "luxor",
        name: "Luxor Temple",
        arabicName: "معبد الأقصر",
        era: .newKingdom,
        tourismType: .pharaonic,
        placeType: .temple,
        city: .luxor,
        shortDescription: "A stunning temple in the heart of modern Luxor, beautiful at night.",
        coordinates: Coordinates(latitude: 25.6996, longitude: 32.6390),
        imageNames: ["luxor_1", "luxor_2"],
        subLocations: [
            SubLocation(
                id: "luxor_entrance",
                name: "The Grand Entrance",
                arabicName: "المدخل الكبير",
                shortDescription: "Massive pylons and the remaining obelisk",
                imageName: "luxor_entrance",
                storyCards: [
                    StoryCard(id: "luxor_e1", type: .intro, imageName: "luxor_pylon", content: "Two massive seated statues of Ramesses II guard the entrance, each standing 50 feet tall.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "luxor_e2", type: .story, imageName: "luxor_obelisk", content: "Originally, two obelisks stood here. One remains in Luxor; the other has been in Paris since 1836.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "luxor_e3", type: .fact, imageName: nil, content: nil, funFact: "The missing obelisk now stands in Place de la Concorde in Paris - a gift from Egypt to France!", quizQuestion: nil)
                ]
            )
        ],
        visitInfo: VisitInfo(
            estimatedDuration: "2-3 hours",
            bestTimeToVisit: "Evening visit recommended - beautifully lit at night",
            tips: [
                "Visit at sunset to see the temple transform",
                "The temple is in central Luxor - easy walk from hotels",
                "Look for the Abu Haggag Mosque built on top"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Temple", arabic: "معبد", pronunciation: "ma'bad"),
                ArabicPhrase(english: "Beautiful", arabic: "جميل", pronunciation: "gameel")
            ]
        ),
        isUnlocked: true
    )

    // MARK: - Valley of the Kings
    static let valleyOfKings = Site(
        id: "valley_kings",
        name: "Valley of the Kings",
        arabicName: "وادي الملوك",
        era: .newKingdom,
        tourismType: .pharaonic,
        placeType: .tomb,
        city: .luxor,
        shortDescription: "The hidden burial ground of Egypt's greatest pharaohs.",
        coordinates: Coordinates(latitude: 25.7402, longitude: 32.6014),
        imageNames: ["valley_1", "valley_2"],
        subLocations: [
            SubLocation(
                id: "tut_tomb",
                name: "Tomb of Tutankhamun",
                arabicName: "مقبرة توت عنخ آمون",
                shortDescription: "The famous tomb of the boy king",
                imageName: "tut_tomb",
                storyCards: [
                    StoryCard(id: "tut_1", type: .intro, imageName: "tut_mask", content: "In 1922, Howard Carter made the discovery of a lifetime - the nearly intact tomb of a young pharaoh.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "tut_2", type: .story, imageName: "tut_discovery", content: "\"Can you see anything?\" Lord Carnarvon asked. \"Yes, wonderful things,\" Carter whispered, peering through a small hole.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "tut_3", type: .fact, imageName: nil, content: nil, funFact: "It took Carter 10 years to catalog all 5,398 objects found in the tomb!", quizQuestion: nil),
                    StoryCard(id: "tut_4", type: .quiz, imageName: nil, content: nil, funFact: nil, quizQuestion: QuizQuestion(
                        id: "q_tut_1",
                        question: "Why was Tutankhamun's tomb so significant?",
                        options: ["It was nearly intact", "It was the largest", "It was the oldest", "It had the most mummies"],
                        correctAnswerIndex: 0,
                        explanation: "Unlike most royal tombs which were robbed in antiquity, Tut's tomb was found nearly intact with all its treasures.",
                        funFact: nil
                    ))
                ]
            )
        ],
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning (6-8 AM) before the heat",
            tips: [
                "Your ticket includes 3 tombs - choose wisely",
                "Tutankhamun's tomb requires a separate ticket",
                "No photography inside the tombs"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Tomb", arabic: "مقبرة", pronunciation: "maqbara"),
                ArabicPhrase(english: "King", arabic: "ملك", pronunciation: "malik")
            ]
        ),
        isUnlocked: true
    )

    // MARK: - Karnak Temple
    static let karnakTemple = Site(
        id: "karnak",
        name: "Karnak Temple Complex",
        arabicName: "معابد الكرنك",
        era: .newKingdom,
        tourismType: .pharaonic,
        placeType: .temple,
        city: .luxor,
        shortDescription: "The largest ancient religious complex ever built.",
        coordinates: Coordinates(latitude: 25.7188, longitude: 32.6573),
        imageNames: ["karnak_1", "karnak_2"],
        subLocations: [
            SubLocation(
                id: "hypostyle_hall",
                name: "Great Hypostyle Hall",
                arabicName: "قاعة الأعمدة الكبرى",
                shortDescription: "134 massive columns in a forest of stone",
                imageName: "hypostyle",
                storyCards: [
                    StoryCard(id: "hypo_1", type: .intro, imageName: "hypostyle_main", content: "You stand among giants. 134 massive columns surround you, the largest standing 69 feet tall.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "hypo_2", type: .story, imageName: "hypostyle_detail", content: "Imagine this space 3,000 years ago: columns painted in brilliant colors, incense smoke drifting through light.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "hypo_3", type: .fact, imageName: nil, content: nil, funFact: "The entire Notre-Dame cathedral could fit inside the Hypostyle Hall!", quizQuestion: nil)
                ]
            )
        ],
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning or evening Sound & Light show",
            tips: [
                "The complex is vast - wear comfortable shoes",
                "Don't miss the Sacred Lake",
                "The Hypostyle Hall is best in morning light"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Column", arabic: "عمود", pronunciation: "amood"),
                ArabicPhrase(english: "Huge", arabic: "كبير", pronunciation: "kebeer")
            ]
        ),
        isUnlocked: true
    )

    // MARK: - Abu Simbel
    static let abuSimbel = Site(
        id: "abu_simbel",
        name: "Abu Simbel",
        arabicName: "أبو سمبل",
        era: .newKingdom,
        tourismType: .pharaonic,
        placeType: .temple,
        city: .aswan,
        shortDescription: "Ramesses II's monumental temple, famously relocated.",
        coordinates: Coordinates(latitude: 22.3372, longitude: 31.6258),
        imageNames: ["abu_simbel_1", "abu_simbel_2"],
        subLocations: [
            SubLocation(
                id: "great_temple",
                name: "Great Temple of Ramesses II",
                arabicName: "معبد رمسيس الثاني الكبير",
                shortDescription: "Four colossal statues guard the entrance",
                imageName: "abu_simbel_facade",
                storyCards: [
                    StoryCard(id: "abu_1", type: .intro, imageName: "abu_facade", content: "Four massive statues of Ramesses II gaze eternally across the Nubian desert, each 65 feet tall.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "abu_2", type: .story, imageName: "abu_interior", content: "Twice a year, on Feb 22 and Oct 22, the rising sun penetrates 185 feet into the mountain to illuminate the inner statues.", funFact: nil, quizQuestion: nil),
                    StoryCard(id: "abu_3", type: .fact, imageName: nil, content: nil, funFact: "The entire temple was moved in the 1960s to save it from flooding! Cut into blocks and reassembled on higher ground.", quizQuestion: nil),
                    StoryCard(id: "abu_4", type: .quiz, imageName: nil, content: nil, funFact: nil, quizQuestion: QuizQuestion(
                        id: "q_abu_1",
                        question: "Why was Abu Simbel moved?",
                        options: ["To save it from Lake Nasser flooding", "It was sinking", "For tourism access", "Political reasons"],
                        correctAnswerIndex: 0,
                        explanation: "The Aswan High Dam would have submerged the temple. UNESCO led an international effort to relocate it.",
                        funFact: nil
                    ))
                ]
            )
        ],
        visitInfo: VisitInfo(
            estimatedDuration: "2-3 hours",
            bestTimeToVisit: "Feb 22 or Oct 22 for the sun festival",
            tips: [
                "Most visitors fly from Aswan",
                "The smaller temple honors Nefertari",
                "Visit the UNESCO relocation exhibition"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Sun", arabic: "شمس", pronunciation: "shams"),
                ArabicPhrase(english: "Amazing", arabic: "مذهل", pronunciation: "muzhil")
            ]
        ),
        isUnlocked: true
    )
}
