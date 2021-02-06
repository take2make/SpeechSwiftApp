import SwiftUI
import UniformTypeIdentifiers
import Firebase
import FirebaseStorage
import UniformTypeIdentifiers



//структура текстового редактора
struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
}

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func listAllFiles() {
    let documentsUrl = getDocumentsDirectory()

    do {
        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
        print(directoryContents)

    } catch {
        print(error)
    }
}

struct AudioFile: Encodable, Decodable{
    var encoded_data: Data
    var ext: String
    var model: String
}


/*
 
Функция для работы с Google firebase storage уже не используется т.к разработан собственный API
func PushFileToServer(localFile: URL, name: String, model:String) {
    if (CFURLStartAccessingSecurityScopedResource(localFile as CFURL)) {
    
        let storage = Storage.storage(url: "gs://sra-7ffa8.appspot.com").reference()
        
        do {
            let audioData = try Data(contentsOf: localFile as URL)
            
            let metadata = StorageMetadata()
                        metadata.contentType = "audio/m4a"
         
            storage.child("audio/\(localFile.lastPathComponent)_\(model)").putData(audioData, metadata: metadata) { (metadata, error) in
             guard let metadata = metadata else {
               // Uh-oh, an error occurred!
               print((error?.localizedDescription)!)
               return
             }
             let size = metadata.size
             
             print("Upload size is \(size)")
             print("Upload success")
         }
        } catch {
            print("Unable to load data: \(error)")
        }
    
    }
    CFURLStopAccessingSecurityScopedResource(localFile as CFURL)
}
*/
//Описание

//Описание API
class SpeechApi: ObservableObject {
    
    @Published var GetStatus = false
    @Published var PostStatus = false
    @Published var doc:MessageDocument = MessageDocument(message: "")
    @Published var SID:Int = -1
    
    
    //Структуры запросов
    struct SPostRes: Decodable {
        var session_id: Int
        var detail: Int
    }
     struct ApiRes: Decodable{
        var session_id: Int
        var result: String
    }
    
    
    //Функция отправки пост запроса с отправкой аудио-файла с устройства
    func SpeachRecApiPostData(localFile: URL, name: String, model:String, _ completion:@escaping (_ id: Int)->Void) {
        //условие снимает зашиту на выбранный файл для его последущей декодировки и отправки на сервер
        if (CFURLStartAccessingSecurityScopedResource(localFile as CFURL)) {
            do {
                let audioData = try Data(contentsOf: localFile as URL)
                //создаем структуру данных для последующей отправки
                let DataR = AudioFile(encoded_data: audioData, ext: localFile.pathExtension, model: model)
                // кодируем данные в JSON-base64 формат
                guard let encoded = try? JSONEncoder().encode(DataR) else {
                    print("Failed to encode order")
                    return
                }
                //задаем url API и тело HTTP-запроса
                let url = URL(string: "http://192.168.1.218:8000/api/speech_api/")!
                var request = URLRequest(url: url)
                request.setValue(
                    "application/json",
                    forHTTPHeaderField: "Content-Type"
                )
                
                let body = encoded
                request.httpMethod = "POST"
                request.httpBody = body
                //Создаем URL-сессию
                let session = URLSession.shared
                //Отправляем запрос на сервер
                let task = session.dataTask(with: request) { (data, response, error) in
                    //обработка ошибок
                    if let error = error {
                        print("Error: \(error)")
                    } else if let data = data {
                        //в случае успеха сервер сообщает нам уникальный SID по которому мы находим результат
                        //декодируем данные от сервера
                        if let decodedOrder = try? JSONDecoder().decode(SPostRes.self, from: data) {
                            //т.к запросы выполняются в отдельном потоке вызываем внешний декоратор который замыкает функцию(т.е вызывается в случае ее завершения)
                            //внутрь замыкания передается SID для дальнейшего использования
                            completion(decodedOrder.session_id)
                        
                        } else {
                        }
                    
                    } else {
                        print("ERROR2")
                    }
                }
                
                task.resume()
            } catch {
                //обработка ошибки с правами доступа к файлу
                print("Unable to load data: \(error)")
            }
        }
        CFURLStopAccessingSecurityScopedResource(localFile as CFURL)
        //выходим из режима снятия защиты с файла
        
    }
    //Функция получения результата от сервера
    func SpeachRecApiGetData(sid: Int,  _ completion:@escaping (_ isSuccess:String, _ status: Bool)->Void) {
        // создаем url API используя уникальный SID
        let url = URL(string: "http://192.168.1.218:8000/api/speech_api/\(sid)/")!
        // создаем GET-запрос
        var request = URLRequest(url: url)
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        request.httpMethod = "GET"
        
        
        //создаем URL-сессию
        let session = URLSession.shared
        
        //выполняем запрос
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                //обработка ошибок и вызов замыкания для обработки ошибки из вне
                completion("", false)
            } else if let data = data {
                if let decodedOrder = try? JSONDecoder().decode(ApiRes.self, from: data) {
                    //т.к запросы выполняются в отдельном потоке вызываем внешний декоратор который замыкает функцию(т.е вызывается в случае ее завершения)
                    //внутрь замыкания передается результат(транскрипция) и флаг успеха для дальнейшего использования
                    completion(decodedOrder.result, true)
                    
                } else {
                    completion("", false)
                }
            } else {
                print("ERROR2")
                completion("", false)
            }
        }
        
        task.resume()
        
    }
    
    
    
    //т.к вышеописанная post-функция использует механизм замыканий для чистоты кода спользуется функция реализующая замыкание
    public func PostRes(localFile: URL, name: String, model:String){
        //Вызов API
        self.SpeachRecApiPostData(localFile: localFile, name: name, model: model) {//начало замыкания
            (res) in
                //т.к функция выполняется в отделльном потоке то чтобы изменить поля класса нужно находится в основном потоке поэтому:
                DispatchQueue.main.async {
                    self.SID = res // мы получили SID от сервера
                }
                //конец замыкания
        }
    }
    
    
    //Получение результата от API
    //Т.к результат работы сервера после нашего POST зпроса появляется не мгновенно нам нужно его дождаться для этого используется асинхронный механизм вызова функции SpeachRecApiGetData c определенным интервало по сути по таймеру это нужно чтобы снизить нагрузку на устройство
    public func GetRes(_ completion:@escaping (_ isSuccess:MessageDocument)->Void){
        //т.к функция выполняется в отделльном потоке то чтобы изменить поля класса нужно находится в основном потоке поэтому:
        DispatchQueue.main.async {
            self.GetStatus = true
        }
        //интервал отправки запров
        let interval = 2.0
        //кол-во запросов
        var count = 0
        //ассинхрнная отпавки и обработка
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: interval,repeats: true) { t in
                //асинхронный вызов функции SpeachRecApiGetData по таймеру
                self.SpeachRecApiGetData(sid: self.SID) {
                    (res, flag) in
                    //обработка результатов ее работы если все "хорошо" то таймер завершается и передает данные в замыкание
                    if flag {
                        DispatchQueue.main.async {
                            self.doc = MessageDocument(message: res)
                            completion(self.doc)
                        }
                        //остановка таймера
                        t.invalidate()
                    }
                }
                //В случае если данные не пришли мы увиличиваем счетчик и снова отправляем запрос
                count+=1
                if count >= 100 {
                    //если данные так и не пришли мы завершаем таймер и устанавливаем флаг ошибки
                    t.invalidate()
                    DispatchQueue.main.async {
                        self.GetStatus = false
                    }
                }
                
            }
        }
    }
    
    
    
}
