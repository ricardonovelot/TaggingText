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
                            viewModel.recognizeTags(newText)
                            print(viewModel.summaryText)
                        }
                        .lineLimit(3...)
                }  footer: {
                    Text("Recognize Languages and Names With Natural Language.")
                }
                
                Section{
                    List(viewModel.suggestions){ suggestion in
                        HStack{
                            Image(systemName: suggestion.image)
                            Text(suggestion.text)
                        }
                    }
                }
                
                
            }
            .toolbar{
                Button {
                    viewModel.generateRandomSample()
                } label: {
                    Image(systemName: "repeat")
                }

            }
            .contentMargins(.top, 16)
            .navigationTitle("TaggingText")
        }
    }
}

struct Suggestion: Identifiable{
    var id = UUID()
    var text: String
    var type: String
    
    var image: String {
        switch self.type {
        case "PlaceName":  {return "building.columns.fill"}()
        case "PersonalName":  {return "person.fill"}()
        case "OrganizationName":  {return "person.3.fill"}()
        default: "percamera.metering.unknown"
        }
    }
}



extension ContentView{
    class ContentViewModifier: ObservableObject{
        let languageRecognizer = NLLanguageRecognizer()
        @Published var inputText = ""
        @Published var summaryText = ""
        @Published var suggestions: [Suggestion] = []
        var lastIndex: Int? = nil
        
        
        let sampleInputTexts = [
            "Hoy participe en UNIDOS, conoci a Andrea y a Luis, fuimos al Museo Papalote en Fundidora",
            "Hoy en TECHO construimos 2 casas, Rey, Cielo a Luis y su familia"
        ]
        
        init(){
            generateRandomSample()
            recognizeTags(inputText)
        }
        
        func generateRandomSample(){
          
            let index = Int.random(in: 0...1)
            if lastIndex == index {
                generateRandomSample()
            } else {
                lastIndex = index
                inputText = sampleInputTexts[index]
            }
        }
 
        func recognizeLanguage(_ text: String)-> NLLanguage? {
          languageRecognizer.reset()
          languageRecognizer.processString(text)
          return languageRecognizer.dominantLanguage
        }
        
        func recognizeTags(_ text: String) {
            let tags: [NLTag] = [.personalName, .placeName, .organizationName]
            let tagger = NLTagger(tagSchemes: [.nameType])
            tagger.string = text
            
            suggestions.removeAll()
        
           // var results: [(String, NLTag)] = []
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
                    suggestions.append(Suggestion(text: String(text[range]), type: tag.rawValue))
                    
                    //results.append((String(text[range]), tag))
                    return true
                })
            return
            
        }
    }
}

#Preview {
    ContentView()
}
