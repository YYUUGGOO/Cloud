import SwiftUI
import LaunchAtLogin

struct settingsView: View {
    @Binding var standardTimer: Int
    @Binding var shortBreak: Int
    @Binding var longBreak: Int

    var body: some View {
        VStack{
            LaunchAtLogin.Toggle()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
            
            HStack{
                VStack{
                    TextField("", value: $standardTimer, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    Text("Standard Timer")
                        .font(.system(size: 9))
                    
                }
                VStack{
                    TextField("", value: $shortBreak, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width:80)
                    Text("Short Break")
                        .font(.system(size: 9))
                }
                VStack{
                    TextField("", value: $longBreak, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    Text("Long Break")
                        .font(.system(size: 9))
                }
                
            }
            
        }
        .frame(width: 300, height: 200)
    }
}


struct settingsView_Previews: PreviewProvider {
    static var previews: some View {
        settingsView(standardTimer: .constant(25), shortBreak: .constant(5), longBreak: .constant(15))
    }
}
