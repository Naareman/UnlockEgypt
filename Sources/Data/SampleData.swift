import Foundation

/// Sample data for the app - replace with JSON loading or API later
struct SampleData {

    // MARK: - Sites
    static let sites: [Site] = [
        gizaPyramids,
        luxorTemple,
        valleyOfKings,
        karnakTemple,
        abuSimbel
    ]

    // MARK: - Giza Pyramids
    static let gizaPyramids = Site(
        id: "giza",
        name: "The Pyramids of Giza",
        arabicName: "أهرامات الجيزة",
        era: .oldKingdom,
        shortDescription: "The last surviving wonder of the ancient world, standing for over 4,500 years.",
        coordinates: Coordinates(latitude: 29.9792, longitude: 31.1342),
        imageNames: ["giza_1", "giza_2", "giza_3"],
        stories: [gizaStory],
        quiz: gizaQuiz,
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning (8-10 AM) or late afternoon to avoid crowds and heat",
            tips: [
                "Bring plenty of water and sun protection",
                "Hire an official guide at the entrance for deeper insights",
                "The interior of the Great Pyramid is hot and cramped - not for claustrophobics",
                "Visit the Solar Boat Museum to see the reconstructed boat of Khufu"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Pyramid", arabic: "هرم", pronunciation: "haram"),
                ArabicPhrase(english: "How much?", arabic: "بكام؟", pronunciation: "bekam?"),
                ArabicPhrase(english: "Thank you", arabic: "شكراً", pronunciation: "shukran"),
                ArabicPhrase(english: "Beautiful", arabic: "جميل", pronunciation: "gameel")
            ]
        ),
        isUnlocked: true
    )

    static let gizaStory = Story(
        id: "giza_story_1",
        title: "Building the Impossible",
        subtitle: "How 100,000 workers achieved the unthinkable",
        chapters: [
            Chapter(
                id: "giza_ch1",
                title: "The Pharaoh's Dream",
                content: """
                In 2560 BCE, Pharaoh Khufu stood at the edge of the Giza plateau, gazing across the desert. He was not just a king—he was a living god, and he needed a tomb worthy of his divine status.

                "Build me a stairway to the heavens," he commanded his vizier Hemiunu. "A monument so grand that it will stand until the end of time."

                Hemiunu bowed low. He knew this was no ordinary request. The pyramid would need to be larger than anything ever built—481 feet tall, using over 2 million stone blocks, each weighing as much as a small elephant.

                The challenge seemed impossible. But Hemiunu had a plan.
                """,
                imageName: "giza_story_1",
                didYouKnow: "The Great Pyramid was the tallest man-made structure in the world for over 3,800 years!"
            ),
            Chapter(
                id: "giza_ch2",
                title: "An Army of Builders",
                content: """
                Contrary to popular myth, the pyramids were not built by slaves. They were constructed by skilled Egyptian workers—farmers during the Nile's flood season when they couldn't tend their fields.

                Workers lived in a nearby village, ate bread and beer, and received medical care. Archaeological evidence shows they were proud of their work, organizing themselves into teams with names like "Friends of Khufu" and "Drunkards of Menkaure."

                The limestone blocks were quarried nearby, but the gleaming white casing stones came from Tura, across the Nile. The granite for the King's Chamber traveled 500 miles from Aswan.

                How did they move these massive stones? Ramps, levers, and the power of human determination.
                """,
                imageName: "giza_story_2",
                didYouKnow: "Workers left graffiti inside the pyramid! One reads: 'The gang, The Drunkards of Menkaure'"
            ),
            Chapter(
                id: "giza_ch3",
                title: "Secrets of the Chambers",
                content: """
                Deep inside the Great Pyramid lies a mystery. Three chambers exist: the underground chamber carved into bedrock, the misnamed "Queen's Chamber," and the magnificent King's Chamber with its red granite sarcophagus.

                But why three chambers? Were the plans changed during construction? Or do hidden chambers still await discovery?

                In 2017, scientists using cosmic ray imaging detected a massive void above the Grand Gallery. Its purpose remains unknown—perhaps a construction feature, or perhaps something more.

                The pyramid keeps its secrets well.
                """,
                imageName: "giza_story_3",
                didYouKnow: "The four sides of the Great Pyramid are aligned almost perfectly with the four cardinal directions—within 0.05 degrees!"
            )
        ],
        audioFileName: "giza_narration.mp3",
        estimatedReadTime: 8,
        perspective: .worker
    )

    static let gizaQuiz = Quiz(
        id: "giza_quiz",
        title: "Test Your Knowledge: Giza",
        questions: [
            QuizQuestion(
                id: "giza_q1",
                question: "Who built the Great Pyramid of Giza?",
                options: ["Pharaoh Khufu", "Pharaoh Tutankhamun", "Cleopatra", "Ramesses II"],
                correctAnswerIndex: 0,
                explanation: "The Great Pyramid was built for Pharaoh Khufu (also known as Cheops) around 2560 BCE during the Old Kingdom.",
                funFact: "Khufu's pyramid is the largest of the three Giza pyramids. His son Khafre and grandson Menkaure built the other two."
            ),
            QuizQuestion(
                id: "giza_q2",
                question: "Who actually built the pyramids?",
                options: ["Skilled Egyptian workers", "Slaves", "Aliens", "Roman soldiers"],
                correctAnswerIndex: 0,
                explanation: "Archaeological evidence shows that skilled Egyptian workers built the pyramids. They were paid laborers who lived in nearby villages.",
                funFact: "Workers received about 4-5 liters of beer per day as part of their payment!"
            ),
            QuizQuestion(
                id: "giza_q3",
                question: "How long did the Great Pyramid remain the world's tallest structure?",
                options: ["Over 3,800 years", "About 500 years", "100 years", "It was never the tallest"],
                correctAnswerIndex: 0,
                explanation: "The Great Pyramid was the tallest man-made structure from ~2560 BCE until the Lincoln Cathedral spire was completed in 1311 CE.",
                funFact: nil
            )
        ],
        passingScore: 2
    )

    // MARK: - Luxor Temple
    static let luxorTemple = Site(
        id: "luxor",
        name: "Luxor Temple",
        arabicName: "معبد الأقصر",
        era: .newKingdom,
        shortDescription: "A stunning temple in the heart of modern Luxor, illuminated beautifully at night.",
        coordinates: Coordinates(latitude: 25.6996, longitude: 32.6390),
        imageNames: ["luxor_1", "luxor_2"],
        stories: [luxorStory],
        quiz: nil,
        visitInfo: VisitInfo(
            estimatedDuration: "2-3 hours",
            bestTimeToVisit: "Evening visit recommended - the temple is beautifully lit at night",
            tips: [
                "Visit at sunset to see the temple transform as lights come on",
                "The temple is in central Luxor - easy to walk from most hotels",
                "Look for the Abu Haggag Mosque built on top of the temple",
                "The avenue of sphinxes connecting to Karnak has been restored"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Temple", arabic: "معبد", pronunciation: "ma'bad"),
                ArabicPhrase(english: "Ancient", arabic: "قديم", pronunciation: "qadeem"),
                ArabicPhrase(english: "Where is...?", arabic: "فين...؟", pronunciation: "fein...?")
            ]
        ),
        isUnlocked: true
    )

    static let luxorStory = Story(
        id: "luxor_story_1",
        title: "Temple of the Living",
        subtitle: "Where pharaohs became gods",
        chapters: [
            Chapter(
                id: "luxor_ch1",
                title: "The Festival of Opet",
                content: """
                Once a year, ancient Thebes erupted in celebration. The Festival of Opet had begun.

                Priests carried the sacred barque of Amun from Karnak Temple, processing down the sphinx-lined avenue to Luxor Temple—a journey of nearly two miles. Musicians played, dancers whirled, and the people lined the route, hoping for a glimpse of the divine.

                At Luxor Temple, something magical happened. The reigning pharaoh would enter the sanctuary and emerge... transformed. The ritual renewed his divine power, confirming his role as the living link between gods and humanity.

                This wasn't just ceremony—it was the spiritual heartbeat of Egypt.
                """,
                imageName: "luxor_opet",
                didYouKnow: "The Festival of Opet lasted 11 days during the reign of Thutmose III, but grew to 27 days under Ramesses III!"
            )
        ],
        audioFileName: nil,
        estimatedReadTime: 4,
        perspective: .priest
    )

    // MARK: - Valley of the Kings
    static let valleyOfKings = Site(
        id: "valley_kings",
        name: "Valley of the Kings",
        arabicName: "وادي الملوك",
        era: .newKingdom,
        shortDescription: "The hidden burial ground of Egypt's greatest pharaohs, including Tutankhamun.",
        coordinates: Coordinates(latitude: 25.7402, longitude: 32.6014),
        imageNames: ["valley_1", "valley_2"],
        stories: [valleyStory],
        quiz: valleyQuiz,
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning (6-8 AM) before the heat becomes intense",
            tips: [
                "Your ticket includes 3 tombs - choose wisely!",
                "Tutankhamun's tomb requires a separate ticket",
                "No photography inside the tombs",
                "Bring water - it gets extremely hot in the valley"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Tomb", arabic: "مقبرة", pronunciation: "maqbara"),
                ArabicPhrase(english: "King", arabic: "ملك", pronunciation: "malik"),
                ArabicPhrase(english: "It's hot", arabic: "الجو حر", pronunciation: "el-gaw harr")
            ]
        ),
        isUnlocked: true
    )

    static let valleyStory = Story(
        id: "valley_story_1",
        title: "The Discovery of Tutankhamun",
        subtitle: "Howard Carter's incredible find",
        chapters: [
            Chapter(
                id: "valley_ch1",
                title: "Years of Searching",
                content: """
                By 1922, Howard Carter was running out of time and money. He had spent years searching the Valley of the Kings for an undiscovered royal tomb, but found nothing significant.

                His patron, Lord Carnarvon, was ready to give up. "One more season," Carter pleaded. "Just one more."

                On November 4, 1922, a water boy's donkey stumbled on a stone step hidden beneath ancient workmen's huts. Carter's team began to dig.

                Twelve steps later, they reached a sealed doorway bearing the royal necropolis seal.

                Carter sent a telegram to Carnarvon: "At last have made wonderful discovery in Valley; a magnificent tomb with seals intact."
                """,
                imageName: "tut_discovery",
                didYouKnow: "The tomb was partially robbed in antiquity, but the robbers were caught! The tomb was resealed and forgotten."
            ),
            Chapter(
                id: "valley_ch2",
                title: "Wonderful Things",
                content: """
                On November 26, 1922, Carter made a small hole in the upper corner of the doorway. Hot air rushed out—air that had been sealed inside for over 3,000 years.

                Carnarvon asked, "Can you see anything?"

                Carter, peering through the hole by candlelight, could barely speak. "Yes," he whispered, "wonderful things."

                The antechamber was packed with treasures: gilded furniture, alabaster vases, golden shrines. And beyond lay the burial chamber, where four nested shrines protected the golden coffins of the boy king.

                Tutankhamun had waited 3,245 years to greet the modern world.
                """,
                imageName: "tut_treasures",
                didYouKnow: "It took Carter 10 years to carefully document and remove all 5,398 objects from the tomb!"
            )
        ],
        audioFileName: "valley_narration.mp3",
        estimatedReadTime: 6,
        perspective: .explorer
    )

    static let valleyQuiz = Quiz(
        id: "valley_quiz",
        title: "Test Your Knowledge: Valley of the Kings",
        questions: [
            QuizQuestion(
                id: "valley_q1",
                question: "Who discovered Tutankhamun's tomb?",
                options: ["Howard Carter", "Heinrich Schliemann", "Jean-François Champollion", "Giovanni Belzoni"],
                correctAnswerIndex: 0,
                explanation: "British archaeologist Howard Carter discovered Tutankhamun's tomb in 1922, funded by Lord Carnarvon.",
                funFact: "Carter had a pet canary that was eaten by a cobra the day the tomb was opened—locals saw it as the pharaoh's revenge!"
            ),
            QuizQuestion(
                id: "valley_q2",
                question: "Why was Tutankhamun's tomb so significant?",
                options: ["It was almost completely intact", "It was the largest tomb", "It had the most mummies", "It was the oldest tomb"],
                correctAnswerIndex: 0,
                explanation: "Unlike most royal tombs which were robbed in antiquity, Tutankhamun's tomb was found nearly intact with all its treasures.",
                funFact: nil
            )
        ],
        passingScore: 1
    )

    // MARK: - Karnak Temple
    static let karnakTemple = Site(
        id: "karnak",
        name: "Karnak Temple Complex",
        arabicName: "معابد الكرنك",
        era: .newKingdom,
        shortDescription: "The largest ancient religious complex ever built, expanded over 2,000 years.",
        coordinates: Coordinates(latitude: 25.7188, longitude: 32.6573),
        imageNames: ["karnak_1", "karnak_2"],
        stories: [karnakStory],
        quiz: nil,
        visitInfo: VisitInfo(
            estimatedDuration: "3-4 hours",
            bestTimeToVisit: "Early morning or attend the Sound & Light show in the evening",
            tips: [
                "The complex is vast - wear comfortable shoes",
                "Don't miss the Sacred Lake and the giant scarab statue",
                "The Hypostyle Hall is most photogenic in early morning light",
                "Evening Sound & Light show tells the temple's story dramatically"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Huge/Great", arabic: "كبير", pronunciation: "kebeer"),
                ArabicPhrase(english: "Column", arabic: "عمود", pronunciation: "amood"),
                ArabicPhrase(english: "God", arabic: "إله", pronunciation: "ilah")
            ]
        ),
        isUnlocked: true
    )

    static let karnakStory = Story(
        id: "karnak_story_1",
        title: "House of Amun",
        subtitle: "2,000 years of divine construction",
        chapters: [
            Chapter(
                id: "karnak_ch1",
                title: "The Great Hypostyle Hall",
                content: """
                You stand among giants. 134 massive columns surround you, the largest standing 69 feet tall and 33 feet in circumference. This is the Great Hypostyle Hall, and nothing in the ancient world could compare.

                Imagine this space 3,000 years ago: the columns painted in brilliant reds, blues, and golds. Incense smoke drifting through shafts of light. Priests in white linen chanting hymns to Amun, king of the gods.

                Construction began under Seti I and was completed by his son, Ramesses II—the same pharaoh who built Abu Simbel. Every surface is covered in carved reliefs depicting religious rituals and military victories.

                This was not just a temple. It was a statement of divine power.
                """,
                imageName: "karnak_hypostyle",
                didYouKnow: "The entire Notre-Dame cathedral could fit inside the Hypostyle Hall!"
            )
        ],
        audioFileName: nil,
        estimatedReadTime: 4,
        perspective: .priest
    )

    // MARK: - Abu Simbel
    static let abuSimbel = Site(
        id: "abu_simbel",
        name: "Abu Simbel",
        arabicName: "أبو سمبل",
        era: .newKingdom,
        shortDescription: "Ramesses II's monumental temple, famously relocated to save it from flooding.",
        coordinates: Coordinates(latitude: 22.3372, longitude: 31.6258),
        imageNames: ["abu_simbel_1", "abu_simbel_2"],
        stories: [abuSimbelStory],
        quiz: nil,
        visitInfo: VisitInfo(
            estimatedDuration: "2-3 hours",
            bestTimeToVisit: "February 22 or October 22 to witness the sun illuminate the inner sanctuary",
            tips: [
                "Most visitors fly from Aswan - it's a 3-hour drive through the desert",
                "The Sound & Light show is spectacular but requires an overnight stay",
                "Visit the exhibition about the UNESCO relocation project",
                "The smaller temple honors Ramesses' wife Nefertari - don't skip it"
            ],
            arabicPhrases: [
                ArabicPhrase(english: "Sun", arabic: "شمس", pronunciation: "shams"),
                ArabicPhrase(english: "Statue", arabic: "تمثال", pronunciation: "timthal"),
                ArabicPhrase(english: "Amazing", arabic: "مذهل", pronunciation: "muzhil")
            ]
        ),
        isUnlocked: true
    )

    static let abuSimbelStory = Story(
        id: "abu_simbel_story_1",
        title: "The Sun King's Vanity",
        subtitle: "Ramesses II's eternal statement of power",
        chapters: [
            Chapter(
                id: "abu_ch1",
                title: "Colossal Ambition",
                content: """
                Four massive statues of Ramesses II gaze eternally across the Nubian desert, each standing 65 feet tall. Their faces are serene, confident—the expression of a pharaoh who believed himself equal to the gods.

                Ramesses II ruled for 66 years, longer than almost any other pharaoh. He fathered over 100 children, built more monuments than any other ruler, and never missed a chance to remind everyone of his greatness.

                Abu Simbel was his masterpiece of propaganda. Carved directly into a sandstone cliff, the temple announced to Nubia and the southern lands: Egypt is powerful. Egypt is eternal. Ramesses is divine.

                And twice a year, on February 22 and October 22, the rising sun penetrates 185 feet into the mountain to illuminate the statues in the innermost sanctuary. Ancient Egyptian engineering at its most sophisticated.
                """,
                imageName: "abu_simbel_facade",
                didYouKnow: "These dates may correspond to Ramesses' birthday and coronation day, though scholars debate this."
            ),
            Chapter(
                id: "abu_ch2",
                title: "The Great Rescue",
                content: """
                In the 1960s, Abu Simbel faced destruction. The construction of the Aswan High Dam would create Lake Nasser, flooding the temple forever.

                UNESCO launched an unprecedented international campaign. Engineers devised an audacious plan: cut the entire temple into blocks, lift them 200 feet up the cliff, and reassemble them on higher ground.

                Between 1964 and 1968, workers cut the temples into over 1,000 blocks, some weighing 30 tons. The blocks were carefully numbered, lifted by crane, and reassembled in an artificial mountain built to replicate the original setting.

                The project cost $40 million (equivalent to over $350 million today) and involved experts from 50 countries. It remains one of archaeology's greatest achievements.

                Ramesses would have approved. His monument endures.
                """,
                imageName: "abu_simbel_rescue",
                didYouKnow: "The artificial dome over the temple is the largest in the world, designed to be invisible from inside."
            )
        ],
        audioFileName: "abu_simbel_narration.mp3",
        estimatedReadTime: 7,
        perspective: .historian
    )

    // MARK: - Sample Quiz (for previews)
    static let sampleQuiz = gizaQuiz
}
