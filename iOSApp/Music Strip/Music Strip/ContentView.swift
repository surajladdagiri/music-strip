//
//  ContentView.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//

import SwiftUI

struct ContentView: View {
    @State var Showerror = false
    @State var ErrorText = ""
    @State var scanning = true
    @State var test = ["A", "B", "C"]
    @State var connecting = false
    @State var con = false
    var body: some View {
            VStack {
                if !connecting{
                    Image(systemName: "wave.3.up.circle.fill")
                        .scaleEffect(3)
                        .foregroundStyle(.tint)
                        .padding(.bottom)
                }
                
                if !scanning{
                    Button("Start Scan"){
                        
                        withAnimation(.default){
                            scanning.toggle()
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                }else{
                    if !connecting{
                    Button("Stop Scan"){
                        withAnimation(.default){
                            scanning.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                        List(test, id: \.self){ peripheral in
                            Button(peripheral){
                                withAnimation{
                                    connecting = true
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .alert("Bluetooth Error", isPresented: $Showerror,actions: {
                Button("Quit"){
                    exit(0)
                }
                Button("OK"){
                    Showerror = false
                }
            }, message: {
                Text("\(ErrorText)")
            })
            if connecting{
                if !con{
                    ZStack{
                        Rectangle()
                            .fill(.gray)
                            .opacity(0.2)
                            .frame(width: 1000, height: 1000)
                        VStack{
                            ZStack{
                                Rectangle()
                                    .fill(.gray)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(20)
                                    .opacity(0.2)
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(2.0)
                                    .tint(.blue)
                            }
                            Text("Connecting...")
                            Button("Simulate"){
                                withAnimation(.linear){
                                    con = true
                                }
                            }
                        }
                    }
                }else{
                    ZStack{
                        Rectangle()
                            .fill(.gray)
                            .opacity(0.2)
                            .frame(width: 1000, height: 1000)
                            .offset(x:-2000)
                        VStack{
                            ZStack{
                                Rectangle()
                                    .fill(.gray)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(20)
                                    .opacity(0.2)
                                    .offset(x:-2000)
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(2.0)
                                    .tint(.blue)
                                    .offset(x:-2000)
                            }
                            Text("Connecting...")
                                .offset(x:-2000)
                            Button("Simulate"){
                                con = true
                            }
                            .offset(x:-2000)
                        }
                    }
                }
                    
                
                
            }
                
        
        
    }
}


#Preview {
    ContentView()
}
