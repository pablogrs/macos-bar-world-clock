import SwiftUI

struct SettingsView: View {
    @ObservedObject var store = TimeZonesStore.shared
    @State private var selectedId = ""
    @State private var newName = ""
    @State private var newFlag = ""
    
    let allTimeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("World Clock Configuration")
                .font(.title2)
                .fontWeight(.bold)
            
            Toggle("Show Local Time (📍)", isOn: $store.showLocal)
                .padding(.horizontal)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Displayed Time Zones")
                    .font(.headline)
                
                List {
                    ForEach(store.selectedTimeZones) { tz in
                        HStack {
                            Text(tz.flag)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text(tz.name)
                                    .font(.body)
                                Text(tz.identifier)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                store.selectedTimeZones.removeAll(where: { $0.id == tz.id })
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(minHeight: 150)
                .listStyle(InsetListStyle())
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Add New Zone")
                    .font(.headline)
                
                HStack {
                    TextField("Label (e.g. Paris)", text: $newName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Flag", text: $newFlag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                }
                
                Picker("Time Zone", selection: $selectedId) {
                    Text("Pick a zone...").tag("")
                    ForEach(allTimeZones, id: \.self) { id in
                        Text(id).tag(id)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                
                Button(action: {
                    if !selectedId.isEmpty && !newName.isEmpty {
                        let config = TimeZoneConfig(
                            name: newName,
                            identifier: selectedId,
                            flag: newFlag.isEmpty ? "🌐" : newFlag
                        )
                        store.selectedTimeZones.append(config)
                        // Reset fields
                        newName = ""
                        newFlag = ""
                        selectedId = ""
                    }
                }) {
                    Label("Add to Bar", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedId.isEmpty || newName.isEmpty)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                Spacer()
                Button("Done") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .frame(width: 450, height: 600)
    }
}
