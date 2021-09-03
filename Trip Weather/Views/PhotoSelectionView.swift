//
//  PhotoSelectionView.swift
//  PhotoSelectionView
//
//  Created by Jonathan Liu on 2/9/21.
//

import SwiftUI

struct PhotoSelectionView: View {
    @State private var showPhotoSheet = false
    @Binding var photoSelectionStatus: AddEditTripView.PhotoSelectionStatus
    @EnvironmentObject var viewModel: TripsViewModel
    
    private func handleImage(_ image: UIImage?) {
        if let image = image {
            viewModel.activeTrip.image = image.jpegData(compressionQuality: 1.0)
            showPhotoSheet = false
            photoSelectionStatus = .selected
        }
    }
    
    private func clearPhoto() {
        photoSelectionStatus = .unselected
        viewModel.activeTrip.image = nil
    }

    

    var body: some View {
        Form {
            Button(action: {
                showPhotoSheet = true
            }) {
                Text("Select photo")
            }
            if photoSelectionStatus == .selected {
                Button(action: {
                    clearPhoto()
                }) {
                    Text("Clear photo")
                        .foregroundColor(.red)
                }
                Section(header: Text("Selected Photo ")) {
                    Image(uiImage: UIImage(data: viewModel.activeTrip.image!)!)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius))
                }

            } else {
                Text("No photo selected")
                    .foregroundColor(.gray)
            }
        }.navigationBarTitle("Select Photo")
            .sheet(isPresented: $showPhotoSheet) {
                PhotoLibrary(handlePickedImage:  { image in
                    handleImage(image)
                })
            }
        
    }
}

