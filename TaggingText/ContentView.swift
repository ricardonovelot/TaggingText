//
//  ContentView.swift
//  TaggingText
//
//  Created by Ricardo on 31/08/24.
//

import SwiftUI
import NaturalLanguage

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModifier()
    
    var body: some View {
        NavigationStack {
            Form{
                Section{
                    TextField("Text", text: $viewModel.inputText, axis: .vertical)
                        .onChange(of: viewModel.inputText) { _, newText in
                            print(newText)
                            if let language = viewModel.recognizeLanguage(newText){
                                print(language)
                            }
                            let recognizedText = viewModel.recognizeTags(newText)
                            
                            let entityText = recognizedText
                                .map { (word, tag) in
                                    "\(word) (\(tag.rawValue))"
                                }
                                .joined(separator: ", ")
                            
                            print(entityText)
                        }
                        .lineLimit(3...)
                }  footer: {
                    Text("Recognize Languages and Names With Natural Language.")
                }
                
                
            }.navigationTitle("TaggingText")
        }
    }
}

extension ContentView{
    class ContentViewModifier: ObservableObject{
        let languageRecognizer = NLLanguageRecognizer()
        @Published var inputText = ""
        
        func recognizeLanguage(_ text: String)-> NLLanguage? {
          languageRecognizer.reset()
          languageRecognizer.processString(text)
          return languageRecognizer.dominantLanguage
        }
        
        func recognizeTags(_ text: String) -> [(String, NLTag)] {
            let tags: [NLTag] = [.personalName, .placeName, .organizationName]
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text
            
            var results: [(String, NLTag)] = []
            tagger.enumerateTags(
                in: text.startIndex..<text.endIndex,
                unit: .word,
                scheme: .nameType,
                options: [.omitWhitespace, .omitPunctuation, .joinNames],
                using: { tag, range in
                    guard let tag = tag, tags.contains(tag) else {
                        return true
                    }
                    
                    print("Found tag \(tag) in text \"\(text[range])\"")
                    results.append((String(text[range]), tag))
                    return true
                })
            return results
            
        }
        
        
        
    }
}

#Preview {
    ContentView()
}
