import SwiftUI
import MapKit

struct ResourcesView: View {
    @ObservedObject var viewModel: ResourcesViewModel
    @State private var showingResourceDetail: Bool = false
    @State private var selectedResource: ResourceItem?
    @State private var showingNearbyLibraries: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Kaynak ara...", text: $viewModel.searchText)
                    .font(.system(size: 16))
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryFilterButton(
                        title: "Tümü",
                        isSelected: viewModel.selectedCategory == nil,
                        onTap: {
                            viewModel.selectCategory(nil)
                        }
                    )
                    
                    ForEach(ResourceCategoryType.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.rawValue,
                            icon: category.icon,
                            color: category.color,
                            isSelected: viewModel.selectedCategory == category,
                            onTap: {
                                viewModel.selectCategory(category)
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            // Resources List
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.filteredResources) { category in
                        ResourceCategoryView(
                            category: category,
                            onSelectResource: { resource in
                                selectedResource = resource
                                
                                // Check if this is the libraries resource
                                if resource.url == "nearby-libraries://" {
                                    showingNearbyLibraries = true
                                } else {
                                    showingResourceDetail = true
                                }
                            },
                            onToggleFavorite: { resourceId in
                                viewModel.toggleFavorite(itemId: resourceId)
                            }
                        )
                    }
                    
                    if viewModel.filteredResources.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("Sonuç bulunamadı")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if !viewModel.searchText.isEmpty {
                                Text("Arama kriterlerinizi değiştirmeyi deneyin")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 50)
                    }
                }
                .padding()
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: 80, height: 80)
                    )
            }
        }
        .sheet(isPresented: $showingResourceDetail) {
            if let resource = selectedResource {
                ResourceDetailView(resource: resource)
            }
        }
        .sheet(isPresented: $showingNearbyLibraries) {
            NavigationView {
                NearbyLibrariesView(viewModel: NearbyLibrariesViewModel())
            }
        }
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String? = nil
    var color: String? = nil
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .white : Color(color ?? "gray"))
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
            )
        }
    }
}

struct ResourceCategoryView: View {
    let category: ResourceCategory
    let onSelectResource: (ResourceItem) -> Void
    let onToggleFavorite: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Category Header
            HStack {
                Image(systemName: category.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(category.type.color))
                
                Text(category.type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text("\(category.items.count) kaynak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Resource Items
            ForEach(category.items) { item in
                ResourceItemView(
                    item: item,
                    onSelect: {
                        onSelectResource(item)
                    },
                    onToggleFavorite: {
                        onToggleFavorite(item.id)
                    }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ResourceItemView: View {
    let item: ResourceItem
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 15) {
                // Resource Icon
                Image(systemName: "doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                // Resource Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: onToggleFavorite) {
                    Image(systemName: item.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18))
                        .foregroundColor(item.isFavorite ? .yellow : .gray)
                }
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ResourceDetailView: View {
    let resource: ResourceItem
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Resource Header
                    VStack(alignment: .center, spacing: 15) {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(15)
                        
                        Text(resource.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                    
                    // Resource Description
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Açıklama")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(resource.description)
                            .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    
                    // Resource Link
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kaynak Bağlantısı")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: resource.url)!) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.blue)
                                
                                Text(resource.url)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .underline()
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                }
                .padding()
            }
            .navigationBarTitle("Kaynak Detayı", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Kapat")
                }
            )
        }
    }
}

#Preview {
    ResourcesView(viewModel: ResourcesViewModel())
}
