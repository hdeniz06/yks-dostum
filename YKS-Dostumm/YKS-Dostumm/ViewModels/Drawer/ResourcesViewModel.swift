import Foundation
import Combine

class ResourcesViewModel: BaseViewModelImpl {
    @Published var resources: [ResourceCategory] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ResourceCategoryType?
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadResources()
    }
    
    func loadResources() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate sample resources
            self.resources = self.generateSampleResources()
            self.isLoading = false
        }
    }
    
    var filteredResources: [ResourceCategory] {
        var filtered = resources
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            filtered = filtered.filter { $0.type == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.map { category in
                let filteredItems = category.items.filter { item in
                    item.title.localizedCaseInsensitiveContains(searchText) ||
                    item.description.localizedCaseInsensitiveContains(searchText)
                }
                return ResourceCategory(type: category.type, items: filteredItems)
            }.filter { !$0.items.isEmpty }
        }
        
        return filtered
    }
    
    func selectCategory(_ category: ResourceCategoryType?) {
        selectedCategory = category
    }
    
    // Helper function to generate sample data
    private func generateSampleResources() -> [ResourceCategory] {
        // Books
        let books = ResourceCategory(
            type: .books,
            items: [
                ResourceItem(
                    id: UUID(),
                    title: "TYT Matematik Soru Bankası",
                    description: "Temel YKS konularını kapsayan kapsamlı bir soru bankası.",
                    url: "https://example.com/tyt-matematik",
                    isFavorite: true
                ),
                ResourceItem(
                    id: UUID(),
                    title: "AYT Fizik Konu Anlatımı",
                    description: "AYT Fizik konularını detaylı anlatan kaynak kitap.",
                    url: "https://example.com/ayt-fizik",
                    isFavorite: false
                ),
                ResourceItem(
                    id: UUID(),
                    title: "TYT-AYT Türkçe Soru Bankası",
                    description: "Türkçe ve Edebiyat konularını kapsayan soru bankası.",
                    url: "https://example.com/turkce-edebiyat",
                    isFavorite: false
                )
            ]
        )
        
        // Videos
        let videos = ResourceCategory(
            type: .videos,
            items: [
                ResourceItem(
                    id: UUID(),
                    title: "Limit Konusu Anlatımı",
                    description: "AYT Matematik Limit konusunun detaylı video anlatımı.",
                    url: "https://example.com/video/limit",
                    isFavorite: true
                ),
                ResourceItem(
                    id: UUID(),
                    title: "Paragraf Çözüm Teknikleri",
                    description: "TYT Türkçe paragraf sorularını çözme teknikleri.",
                    url: "https://example.com/video/paragraf",
                    isFavorite: false
                ),
                ResourceItem(
                    id: UUID(),
                    title: "Kimyasal Tepkimeler",
                    description: "AYT Kimya kimyasal tepkimeler konusu anlatımı.",
                    url: "https://example.com/video/kimyasal-tepkimeler",
                    isFavorite: false
                )
            ]
        )
        
        // Websites
        let websites = ResourceCategory(
            type: .websites,
            items: [
                ResourceItem(
                    id: UUID(),
                    title: "YÖK Atlas",
                    description: "Üniversite ve bölüm tercihlerinde yardımcı platform.",
                    url: "https://yokatlas.yok.gov.tr",
                    isFavorite: true
                ),
                ResourceItem(
                    id: UUID(),
                    title: "ÖSYM",
                    description: "Sınav takvimi ve duyurular için resmi site.",
                    url: "https://www.osym.gov.tr",
                    isFavorite: true
                ),
                ResourceItem(
                    id: UUID(),
                    title: "MEB",
                    description: "Eğitim içerikleri ve duyurular.",
                    url: "https://www.meb.gov.tr",
                    isFavorite: false
                )
            ]
        )
        
        // Documents
        let documents = ResourceCategory(
            type: .documents,
            items: [
                ResourceItem(
                    id: UUID(),
                    title: "YKS Konuları ve Kazanımları",
                    description: "ÖSYM tarafından belirlenen YKS konuları ve kazanımları listesi.",
                    url: "https://example.com/docs/yks-konulari",
                    isFavorite: false
                ),
                ResourceItem(
                    id: UUID(),
                    title: "Üniversite Tercih Kılavuzu",
                    description: "Üniversite tercihlerinde dikkat edilmesi gerekenler.",
                    url: "https://example.com/docs/tercih-kilavuzu",
                    isFavorite: false
                ),
                ResourceItem(
                    id: UUID(),
                    title: "Çalışma Programı Şablonu",
                    description: "Haftalık çalışma programı oluşturmak için şablon.",
                    url: "https://example.com/docs/program-sablonu",
                    isFavorite: true
                )
            ]
        )
        
        // Libraries
        let libraries = ResourceCategory(
            type: .libraries,
            items: [
                ResourceItem(
                    id: UUID(),
                    title: "Yakınımdaki Kütüphaneler",
                    description: "Konumunuza yakın kütüphaneleri ve çalışma alanlarını bulun.",
                    url: "nearby-libraries://",
                    isFavorite: false
                )
            ]
        )
        
        return [books, videos, websites, documents, libraries]
    }
    
    func toggleFavorite(itemId: UUID) {
        for i in 0..<resources.count {
            if let itemIndex = resources[i].items.firstIndex(where: { $0.id == itemId }) {
                resources[i].items[itemIndex].isFavorite.toggle()
                break
            }
        }
    }
}

// Models used by the Resources
enum ResourceCategoryType: String, CaseIterable {
    case books = "Kitaplar"
    case videos = "Videolar"
    case websites = "Web Siteleri"
    case documents = "Dökümanlar"
    case libraries = "Yakınımdaki Kütüphaneler"
    
    var icon: String {
        switch self {
        case .books: return "book.fill"
        case .videos: return "play.rectangle.fill"
        case .websites: return "globe"
        case .documents: return "doc.fill"
        case .libraries: return "building.columns.fill"
        }
    }
    
    var color: String {
        switch self {
        case .books: return "blue"
        case .videos: return "red"
        case .websites: return "green"
        case .documents: return "orange"
        case .libraries: return "purple"
        }
    }
}

struct ResourceCategory: Identifiable {
    var id = UUID()
    var type: ResourceCategoryType
    var items: [ResourceItem]
}

struct ResourceItem: Identifiable {
    var id: UUID
    var title: String
    var description: String
    var url: String
    var isFavorite: Bool
}
