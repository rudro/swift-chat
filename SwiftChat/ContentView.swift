//
//  ContentView.swift
//  SwiftChat
//
//  Created by Cyril Zakka on 4/3/23.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.openURL) var openURL
    
    @State private var config = GenerationConfiguration()
    @State private var prompt = "Write a recipe for chocolate chip cookies"
    @State private var modelURL: URL? = nil                     // TODO: read from defaults
    @State private var languageModel: LanguageModel? = nil
    
    enum ModelLoadingState {
        case noModel
        case loading
        case ready
    }
    @State private var status: ModelLoadingState = .noModel
    
    
    func modelDidChange(url: URL?) {
        guard let url = url else { return }
        
        status = .loading
        Task.init {
            let loader = ModelLoader(url: url)
            do {
                languageModel = try await loader.load()
                status = .ready
            } catch {
                print("Error loading \(url): \(error)")
                status = .noModel
            }
        }
    }

    func run() {
        config.prompt = prompt
        // TODO: send prompt
    }
    
    @ViewBuilder
    var runButton: some View {
        switch status {
        case .noModel:
            EmptyView()
        case .loading:
            ProgressView().controlSize(.small).padding(.trailing, 6)
        case .ready:
            Button(action: run) { Label("Run", systemImage: "play.fill") }
                .keyboardShortcut("R")
        }
    }
    
    var body: some View {
        NavigationSplitView {
            ControlView(prompt: prompt, config: $config, model: $modelURL)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            TextEditor(text: $prompt)
                .font(.body)
                .fontDesign(.rounded)
                .scrollContentBackground(.hidden)
                .lineSpacing(10)
                .padding()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        runButton
                    }
                }
        }.onAppear {
            modelDidChange(url: modelURL)
        }
        .onChange(of: modelURL) { model in
            modelDidChange(url: modelURL)
        }
//        .onChange(of: completer.status) { status in
//            switch status {
//            case .missingModel, .idle, .working, .starting:
//                print("Error")
//            case .progress, .done:
//                promptArea = completer.status.response!.result
//            case .failed(let error):
//                print("\(error)")
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}