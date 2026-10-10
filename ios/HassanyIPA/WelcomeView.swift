import SwiftUI

struct WelcomeView: View {
    @State private var license = ""
    @State private var status = "التفعيل يحتاج ربط السيرفر"
    private let purple = Color(red: 0.51, green: 0.25, blue: 0.98)

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, Color(red: 0.13, green: 0.07, blue: 0.24)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(purple)
                Text("HASSANY IPA")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("أهلاً وسهلاً بيك في Hassany IPA")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
                Text("المطور: @OM_G9").foregroundStyle(.gray)
                Link("قناة التلغرام @hassanyIPA", destination: URL(string: "https://t.me/hassanyIPA")!)
                    .foregroundStyle(.cyan)
                VStack(alignment: .leading, spacing: 12) {
                    Text("كود التفعيل").font(.headline).foregroundStyle(.white)
                    TextField("أدخل كودك", text: $license)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    Button("تفعيل") {
                        status = "ميزة التفعيل غير متصلة بسيرفر بعد"
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(purple)
                    .disabled(license.isEmpty)
                    Text(status).font(.footnote).foregroundStyle(.white.opacity(0.7))
                }
                .padding()
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 22))
                Spacer()
            }
            .padding(24)
        }
    }
}
