
import SwiftUI

struct ProgressBar: View {
    
    @State private var isLoading = false
     
        var body: some View {
            ZStack {
                //серая окружность внутри которой вращаются цветные
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 14)
                    .frame(width: 100, height: 100)
                Section{
                    //цветные сегменты окружности и их анимация
                    Circle()
                        .trim(from: 0, to: 0.1)
                        .stroke(Color.init(#colorLiteral(red: 0.6290636659, green: 0.392329812, blue: 0.8282325864, alpha: 1)), lineWidth: 7)
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear() {
                            self.isLoading = true
                    }
                    Circle()
                        .trim(from: 0.1, to: 0.2)
                        .stroke(Color.init(#colorLiteral(red: 0.2515810132, green: 0.7233806252, blue: 0.8876472116, alpha: 1)), lineWidth: 7)
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear() {
                            self.isLoading = true
                    }
                    Circle()
                        .trim(from: 0.2, to: 0.3)
                        .stroke(Color.init(#colorLiteral(red: 0.9999400973, green: 0.7932888865, blue: 0.2658957243, alpha: 1)), lineWidth: 7)
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear() {
                            self.isLoading = true
                    }
                    Circle()
                        .trim(from: 0.3, to: 0.4)
                        .stroke(Color.init(#colorLiteral(red: 1, green: 0.4494202137, blue: 0.4372800589, alpha: 1)), lineWidth: 7)
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear() {
                            self.isLoading = true
                    }
                }
            }
        }
}

