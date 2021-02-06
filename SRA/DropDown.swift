
import SwiftUI
//меню выбора модели
struct DropDown: View {
    @Binding var model: String
    @State var expand = false
    //список моделей
    @State var target = ["ru hard", "ru simple", "en simple"]
    var body: some View {
        VStack(spacing: 30){
            HStack {
                Text("\(model)")
                    .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                    .bold()
                Image(systemName: expand ? "chevron.up": "chevron.down"  )
                    .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
            } .onTapGesture {
                //обработка нажатия и последующая анимация
                self.expand.toggle()
            }
            if expand {
                //кнопка модели 1
                Button(action: {
                    self.expand.toggle()
                    self.model = "ru hard"
                }, label: {
                    Text("\(target[0])")
                        .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                        .bold()
                })
                //кнопка модели 2
                Button(action: {
                    self.expand.toggle()
                    self.model = "ru simple"
                }, label: {
                    Text("\(target[1])")
                        .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                        .bold()
                })
                //кнопка модели 1
                Button(action: {
                    self.expand.toggle()
                    self.model = "en simple"
                }, label: {
                    Text("\(target[2])")
                        .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                        .bold()
                })
            }
        }
        .padding()
        .background(
            Rectangle()
                .frame(width: 190)
                .foregroundColor(Color.init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                .cornerRadius(20.0)
                .animation(.spring())
        )
    }
}
