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
                    Text("Recognize Names, Places and Organizations with Natural Language Processing")
                }
                
                Section{
                    List(viewModel.suggestions){ suggestion in
                        HStack{
                            Image(systemName: suggestion.image)
                                .foregroundStyle(Color(uiColor: .tintColor))
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
        case "PlaceName":  {return "mappin.and.ellipse"}()
        case "PersonalName":  {return "person.fill"}()
        case "OrganizationName":  {return "person.2.fill"}()
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
            "Today I participated in the UNIDOS, met Sarah and John, we went to the Papalote Museum in Fundidora.",
            "Today at TECHO, we built 2 houses for Mike, Emma, David, and his family.",
            "Jessica, Chris, Emily, climbing group in Ciénega de Gonzalez."
        ]
        
        init(){
            generateRandomSample()
            recognizeTags(inputText)
        }
        
        func generateRandomSample(){
          
            let index = Int.random(in: 0...sampleInputTexts.count-1)
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
