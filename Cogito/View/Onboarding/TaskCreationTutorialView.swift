// TaskCreationTutorialView.swift
struct TaskCreationTutorialView: View {
    @State private var showingDemoTask = false
    @State private var demoTitle = ""
    @State private var demoPriority = Task.Priority.medium
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your First Task")
                .font(.title)
                .bold()
            
            // Interactive Demo Task Form
            VStack(alignment: .leading, spacing: 15) {
                Text("Try it out!")
                    .font(.headline)
                
                TextField("Enter task title", text: $demoTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(themeManager.currentTheme.primaryColor, lineWidth: 2)
                    )
                
                HStack {
                    Text("Priority:")
                    Picker("Priority", selection: $demoPriority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    withAnimation {
                        showingDemoTask = true
                    }
                }) {
                    Text("Preview Task")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
            
            if showingDemoTask {
                // Demo Task Preview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your Task Preview:")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                        
                        Text(demoTitle.isEmpty ? "Sample Task" : demoTitle)
                            .font(.body)
                        
                        Spacer()
                        
                        PriorityBadge(priority: demoPriority)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding()
                .transition(.move(edge: .bottom))
            }
            
            Spacer()
        }
        .padding()
    }
}
