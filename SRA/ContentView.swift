
import SwiftUI
import Firebase
import FirebaseStorage
import UniformTypeIdentifiers

struct ContentView: View {
    @State var importFiles = false
    @State private var document: MessageDocument = MessageDocument(message: "Обработка...")
    @State var model = "Выберите модель"
    @State var PathToFile: URL = URL(fileURLWithPath: "/Выберите файл")
    @State var ConvertStatus = false
    @State var ShowAlert = false
    @State var isExporting = false
    @State var ShowSaveBotton = false
    @State var ResStatus = false
    @ObservedObject var SApi: SpeechApi = SpeechApi()
    @ObservedObject var imageService = ImageService()
    var body: some View {
        ZStack(){
            Color.init(#colorLiteral(red: 0.9352622628, green: 0.9353966117, blue: 0.9352328777, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            VStack(){
                // Hstak - разноцветная линия сверху окна
                HStack(spacing: 0){
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 1, green: 0.4494202137, blue: 0.4372800589, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.9999400973, green: 0.7932888865, blue: 0.2658957243, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.2515810132, green: 0.7233806252, blue: 0.8876472116, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.6290636659, green: 0.392329812, blue: 0.8282325864, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 1, green: 0.4494202137, blue: 0.4372800589, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.9999400973, green: 0.7932888865, blue: 0.2658957243, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.2515810132, green: 0.7233806252, blue: 0.8876472116, alpha: 1)))
                        .frame(width: 75, height: 3)
                    Rectangle()
                        .foregroundColor(Color.init(#colorLiteral(red: 0.6290636659, green: 0.392329812, blue: 0.8282325864, alpha: 1)))
                        .frame(width: 75, height: 3)
                        
                }
                .padding(Edge.Set.top, 10.0)
                Spacer()
                VStack{
                    //Hstack эмблема микрофона с названием приложения
                    HStack{
                        Image(systemName: "mic.fill")
                            .font(.system(size: 35))
                            .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                        HStack(spacing: 0) {
                            Text("AUDIO2")
                                .font(.system(size: 25))
                                .bold()
                            Text("TEXT")
                                .font(.system(size: 25))
                        }
                    }
                } .padding(Edge.Set.bottom, 30.0)
                .padding(Edge.Set.top, 30.0)
                
                VStack{
                    //кнопка для выбора файла
                    Button(action: {
                        //Измения параметр importFiles мы вызываем метод importFile
                        self.importFiles.toggle()
                    }, label: { // дизайн кнопки
                        HStack{
                                Text("\(self.PathToFile.lastPathComponent)")
                                    .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                                    .bold()
                                    .frame(width: 150)
                                    .lineLimit(1)
                            
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .frame(width: 190)
                                .foregroundColor(Color.init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                .cornerRadius(20.0)
                                .animation(.spring())
                        )
                    })
                    //кнопка выбора модели она прописана в отдельном файле DropDown.swift
                    DropDown(model: self.$model)
                        
                    //кнопка получения резкльтата
                    Button(action: {
                        if model != "Выберите модель" {
                            //выставляем флаги для анимации загрузки и статуса траскрипции
                            self.ResStatus = false
                            self.ConvertStatus = true
                            
                            //формируем POST-запрос к Api
                            //Api описано в файле MessageDocument.swift в классе SpeechApi
                            self.SApi.PostRes(localFile: self.PathToFile, name: "audio", model: self.model)
                            //Формируем GET-запрос к Api для получения транскрипции
                            self.SApi.GetRes(){(res) in
                                //полученную транскрипцию отображаем в текстовом редакторе на главном окне
                                self.document = res
                                //отображаем кнопку получения результата
                                self.ResStatus = true
                            }
                            
                        } else {
                            //обработка ошибки отсутствия выбора модели/файла
                            self.ShowAlert.toggle()
                        }
                        
                        
                    }, label: {
                        // дизайн кнопки
                        HStack{
                            Image(systemName: "arrow.down.doc.fill")
                                .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                            Text("Получить результат")
                                .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                                .bold()
                            
                        }
                        .padding()
                        .background(
                            Rectangle()
                                .frame(width: 190)
                                .foregroundColor(Color.init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                .cornerRadius(20.0)
                                .animation(.spring())
                        )
                        .alert(isPresented: self.$ShowAlert) {
                            Alert(title: Text("Ошибка"), message: Text("Выберите модель"), dismissButton: .default(Text("Ок")))

                        }
                    })
                    .padding(Edge.Set.bottom, 30.0)
                    //отображение текстового редактора и кнопки сохранения
                    if self.ConvertStatus {
                        if self.ResStatus == false {
                            ProgressBar()
                                .padding(Edge.Set.top, 80)
                        } else {

                            TextEditor(text: $document.message)
                                .frame(width: UIScreen.main.bounds.size.width - 50, height: 200)
                                .cornerRadius(10.0)
                                .padding(Edge.Set.bottom, 30.0)
                            Button(action: {
                                self.isExporting.toggle()
                            }, label: {
                                HStack{
                                        Text("Сохранить на диск")
                                            .foregroundColor(Color.init(#colorLiteral(red: 0.1848070025, green: 0.2164911628, blue: 0.2460046411, alpha: 1)))
                                            .bold()
                                            .frame(width: 150)
                                            .lineLimit(1)
                                    
                                }
                                .padding()
                                .background(
                                    Rectangle()
                                        .frame(width: 190)
                                        .foregroundColor(Color.init(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                        .cornerRadius(20.0)
                                        .animation(.spring())
                                )
                            })
                        }
                    }
                    
                    Spacer()
                    
                    //нижняя полоска
                    HStack(spacing: 0 ){
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 1, green: 0.4494202137, blue: 0.4372800589, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.9999400973, green: 0.7932888865, blue: 0.2658957243, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.2515810132, green: 0.7233806252, blue: 0.8876472116, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.6290636659, green: 0.392329812, blue: 0.8282325864, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 1, green: 0.4494202137, blue: 0.4372800589, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.9999400973, green: 0.7932888865, blue: 0.2658957243, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.2515810132, green: 0.7233806252, blue: 0.8876472116, alpha: 1)))
                            .frame(width: 75, height: 3)
                        Rectangle()
                            .foregroundColor(Color.init(#colorLiteral(red: 0.6290636659, green: 0.392329812, blue: 0.8282325864, alpha: 1)))
                            .frame(width: 75, height: 3)
                            
                    }
                    .padding(Edge.Set.bottom, 10.0)
                }
            }
        }//методы импорта/экспорта файлов
        .fileImporter(
            isPresented: $importFiles, allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                do {
                    let selectedFiles = try result.get()
                    
                    self.PathToFile = selectedFiles[0]
                    
                    print(selectedFiles)
                    
                } catch {
                    print("failed")
                }
            }
        .fileExporter(
                    isPresented: $isExporting,
                    document: document,
                    contentType: UTType.plainText,
                    defaultFilename: "ResultText"
                ) { result in
                    if case .success = result {
                        // Handle success.
                    } else {
                        // Handle failure.
                    }
                }
    }
}




