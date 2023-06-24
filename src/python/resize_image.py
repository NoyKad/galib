from PIL import Image

def resize(image, size):
    return image.resize(size)

def save_image(image, filename):
    image.save(filename)

if __name__ == "__main__":

    size = 100

    path = 'data/docker_copy.png'
    image = Image.open(path)
    image = resize(image, (size, size))
    save_image(image, f'data/docker_1ch_s{size}x{size}.png')