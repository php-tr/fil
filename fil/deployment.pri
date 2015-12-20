
# Generate QRC File automatically

# handle Scalable image sizes
SCALABLE_IMAGE_SIZES = 3 2 1
INITIAL_IMAGE_SIZE = 4

equals(LOCAL_DEV, "1") {
    INITIAL_IMAGE_SIZE = 2
    SCALABLE_IMAGE_SIZES = ""
    SCALABLE_IMAGE_REBUILD = 0
}

EXTENSIONS =
for (imageFile, SCALABLE_IMAGES) {
    fullImagePath = $${SCALABLE_IMAGE_PATH}/$${INITIAL_IMAGE_SIZE}x/$${imageFile}
    imageFileParts = $$split(imageFile, .)
    imageFileExtension = $$last(imageFileParts)

    !contains(EXTENSIONS, $$imageFileExtension) {
        EXTENSIONS += $$imageFileExtension
    }

    RESOURCE_FILES += $$fullImagePath

    equals(SCALABLE_IMAGE_REBUILD, "1") {
        for (imageSize, SCALABLE_IMAGE_SIZES) {
            scalableImagePath = $${SCALABLE_IMAGE_PATH}/$${imageSize}x/$${imageFile}
            copyCommand = "cp -f $$fullImagePath $$scalableImagePath;"
            message("Copying $$imageFile from 4x to $${imageSize}x. $${copyCommand} $$system($$copyCommand)")
        }
    }
}

equals(SCALABLE_IMAGE_REBUILD, "1") {
    for (imageSize, SCALABLE_IMAGE_SIZES) {
        resizeRatio = $$system("echo $(($$imageSize * 25));")
        for (imageFile, SCALABLE_IMAGES) {
            fullPath = $${SCALABLE_IMAGE_PATH}/$${imageSize}x/$${imageFile}

            resizeCommand = "/opt/ImageMagick/bin/mogrify -strip -resize $${resizeRatio}% $${fullPath};"
            message("Image resizing for $${currentPwd} $${fullPath}. $$system($$resizeCommand)")

            # check duplicate mogrify artifacts
            # X-0.png X-1.png
            # mogrify trims images if there are transparent edges
            zeroImage = $${SCALABLE_IMAGE_PATH}/$${imageSize}x/$$replace(imageFile, .$$imageFileExtension, -0.$${imageFileExtension})
            oneImage = $${SCALABLE_IMAGE_PATH}/$${imageSize}x/$$replace(imageFile, .$$imageFileExtension, -1.$${imageFileExtension})
            exists($$zeroImage):exists($$oneImage) {
                moveCommand = "mv -f $$zeroImage $$fullPath; rm -f $$oneImage;"
                message("Cleaning mogrify artifacts. $$system($$moveCommand)")
            }
        }
    }
}

for (imageFile, SCALABLE_IMAGES) {
    imageFileParts = $$split(imageFile, .)
    imageFileExtension = $$last(imageFileParts)

    for (imageSize, SCALABLE_IMAGE_SIZES) {
        fullPath = $${SCALABLE_IMAGE_PATH}/$${imageSize}x/$${imageFile}
        RESOURCE_FILES += $$fullPath
    }
}

# target resource file
RESOURCE_TARGET = $$OUT_PWD/$${TARGET}.qrc

# generate QRC content using RESORCE_FILES
RESOURCE_CONTENT = \
    "<RCC>" \
        "<qresource prefix=\"/\">"

for(current, RESOURCE_FILES) {
    currentAbsolutePath = $$absolute_path($$current)
    currentRelativePath = $$relative_path($$currentAbsolutePath, $$_PRO_FILE_PWD_)

    currentRelativePathTarget = $$relative_path($$currentAbsolutePath, $$OUT_PWD)
    RESOURCE_CONTENT += "<file alias=\"$${currentRelativePath}\">$${currentRelativePathTarget}</file>"
}

RESOURCE_CONTENT += \
        "</qresource>" \
    "</RCC>"

write_file($$RESOURCE_TARGET, RESOURCE_CONTENT)|error("Could not generate resource file. Aborting.");

# set generated resource file
RESOURCES += $$RESOURCE_TARGET

# let know the Qt Creator of these files
OTHER_FILES += $$RESOURCE_FILES $$RESOURCE_TARGET

# Deploy compiled libraries to correct android paths
android-no-sdk {
    target.path = /data/user/qt
    export(target.path)
    INSTALLS += target
} else:android {
    x86 {
        target.path = /libs/x86
    } else: armeabi-v7a {
        target.path = /libs/armeabi-v7a
    } else {
        target.path = /libs/armeabi
    }
    export(target.path)
    INSTALLS += target
} else:unix {
    isEmpty(target.path) {
        qnx {
            target.path = /tmp/$${TARGET}/bin
        } else {
            target.path = /opt/$${TARGET}/bin
        }
        export(target.path)
    }
    INSTALLS += target
}

export(INSTALLS)

