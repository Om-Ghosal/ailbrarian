from PyPDF2 import PdfReader

def save_images_from_pdf(pdf_path, output_folder):
    # Open the PDF file
    
        reader = PdfReader(pdf_path)

        # Extract images from each page and save them to the output folder
        index = 0
        first_page = reader.pages[index]
        while("/XObject" not in first_page["/Resources"]):
            index +=1

        first_page = reader.pages[index]
        if "/XObject" in first_page["/Resources"]:
                xObject = first_page["/Resources"]["/XObject"].get_object()
                for obj in xObject:
                    if xObject[obj]["/Subtype"] == "/Image":
                        # Save the image
                        size = (xObject[obj]["/Width"], xObject[obj]["/Height"])
                        data = xObject[obj].get_data()
                        with open(output_folder, "wb") as img_file:
                            img_file.write(data)
                        return f"Image saved to {output_folder}"
        else:             
            return "No image found"