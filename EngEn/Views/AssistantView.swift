//
//  AssistantView.swift
//  EngEn
//
//  Created by Loaner on 4/8/23.
//

import SwiftUI


struct AssistantView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var isRecordingStopped = false
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var city = ""
    @State private var date = ""
    @State private var showConfirmationPopup = false
    @ObservedObject var aiModel = AIModel()
    @State var text = ""
    @State var openAIRespond = [String]()
    
    
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                Text("I can schedule reminder for you:")
                    .bold()
                    .font(.title3)
                Divider()
                HStack {
                    Text("Say:")
                    Text("'Schedule a reminder for John Smith in San Francisco on April 15th at 2:00 PM' and then press Stop Recording")
                        .font(.caption)
                        .italic()
                }
                
                
            }
            Image(systemName: isRecording ? "mic" : "mic.slash")
                .aspectRatio(contentMode: .fill)
                .foregroundColor(Color.green)
                .font(.title)
                .padding()
                .accessibilityLabel(isRecording ? "with transcription" : "without transcription")
            
            //            Text("Verify that the reminder details are correct and confirm the reminder to schedule it.")
            
            
            VStack {
                Button(action: {
                    if isRecording {
                        aiModel.setup()
                        speechRecognizer.stopTranscribing()
                        isRecordingStopped = false
                        send(text: "extract variables for First Name, Last Name, City and DateTime: \(speechRecognizer.transcript)")
                        if !date.isEmpty{
                            showConfirmationPopup = true
                        }
                        
                    } else {
                        speechRecognizer.reset()
                        speechRecognizer.transcribe()
                        isRecordingStopped = true
                        
                    }
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                Text("")
                Text("\(speechRecognizer.transcript)")
                Text("")
                ForEach(openAIRespond, id: \.self) { string in
                    Text(string)
                }
                
                Text("Note: It's important to speak clearly and in a quiet environment to ensure accurate voice recognition. Also, be sure to provide all the necessary details for the reminder to be properly scheduled.")
                    .italic()
                    .font(.caption2)
            }
        }
        .padding()
        .alert(isPresented: $showConfirmationPopup) {
            if let contact = findContact(firstName: firstName, lastName: lastName, city: city) {
                // Contact is found in core data, show confirmation popup
                return Alert(
                    title: Text("Confirm Reminder"),
                    message: Text("Are you sure you want to schedule a reminder for \(firstName) \(lastName) in \(city) on \(date)?"),
                    primaryButton: .default(Text("Yes")) {
                        contact.reminder = true
                        scheduleReminder(forFName: firstName, forLName: lastName, inCity: city, onDate: date)
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            } else {
                // Contact not found in core data, show error popup
                return Alert(
                    title: Text("Error"),
                    message: Text("Could not find contact with first name \(firstName), last name \(lastName), and city \(city) in your contacts."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    func send(text: String){
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        aiModel.send(text: text){ response in
            DispatchQueue.main.async {
                let components = response.components(separatedBy: "\n")
                    
                    for component in components {
                        if component.contains("First Name:") {
                            firstName = component.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)
                            print(firstName)
                        } else if component.contains("Last Name:") {
                            lastName = component.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)
                            print(lastName)
                        } else if component.contains("City:") {
                            city = component.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces)
                            print(city)
                        } else if component.contains("DateTime:") {
                            date = String(component.dropFirst(10))
                            print(date)
                        }
                    }
                showConfirmationPopup = true
            }
            
        }
    }
}

struct AssistantView_Previews: PreviewProvider {
    static var previews: some View {
        AssistantView()
    }
}
