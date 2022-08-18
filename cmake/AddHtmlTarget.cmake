#
# Functions to generate html documentation
#
# Paremeters:
# - docname: basename of the main xml file. Will be used to locate
#            this primary xml file and for various output files/directories
# - lang: language of the current document
# - entities: list of all xml files this document is composed of
# - figdir: name of the directory holding the images

function (add_html_target docname lang entities figures)

    set(styledir "${CMAKE_SOURCE_DIR}/stylesheet")
    file(GLOB styleicons "${CMAKE_SOURCE_DIR}/stylesheet/*.png")
    set(BUILD_DIR "${DOCDIR_BUILD}/${lang}/${docname}")


    # Convert xml to html with xsltproc
    # xsltproc --xinclude -o outputdir/ /usr/share/sgml/docbook/xsl-stylesheets/html/chunk.xsl filename.xml
    add_custom_command(
      OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/htmltrigger"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_DIR}"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_DIR}/figures"
      COMMAND ${CMAKE_COMMAND} -E make_directory "${BUILD_DIR}/stylesheet"
        COMMAND  ${XSLTPROC} ${XSLTPROCFLAGS} ${XSLTPROCFLAGS_HTML}
                             -o "${BUILD_DIR}/"
                             --param use.id.as.filename "1"
                             --stringparam chunker.output.encoding UTF-8
                             "${CMAKE_SOURCE_DIR}/xsl/general-customization.xsl"
                             "${CMAKE_CURRENT_SOURCE_DIR}/${docname}.xml"
        COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/htmltrigger"
        DEPENDS ${entities} "${docname}.xml" "${CMAKE_SOURCE_DIR}/docbook/gnc-docbookx.dtd")

    # Copy figures for this document
    set(source_figures "")
    foreach(figure ${figures})
        list(APPEND source_figures "${CMAKE_CURRENT_SOURCE_DIR}/${figure}")
    endforeach()

    set(dest_figures "")
    foreach(figure ${figures})
        list(APPEND dest_figures "${BUILD_DIR}/${figure}")
    endforeach()

    if(dest_figures)
        add_custom_command(
            OUTPUT ${dest_figures}
            COMMAND ${CMAKE_COMMAND} -E copy ${source_figures} "${BUILD_DIR}/figures"
            COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/html_figtrigger"
            DEPENDS ${source_figures} "${CMAKE_CURRENT_BINARY_DIR}/htmltrigger")
    endif()

    # Copy style icons for this document (warning, info,...)
    add_custom_command(
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/styletrigger"
        COMMAND  ${CMAKE_COMMAND} -E copy ${styleicons} "${BUILD_DIR}/stylesheet"
        COMMAND touch "${CMAKE_CURRENT_BINARY_DIR}/styletrigger"
        DEPENDS ${styleicons} "${CMAKE_CURRENT_BINARY_DIR}/htmltrigger")

    add_custom_target("${lang}-${docname}-html"
        DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/htmltrigger"
                ${dest_figures}
                "${CMAKE_CURRENT_BINARY_DIR}/styletrigger")

    add_dependencies(${docname}-html "${lang}-${docname}-html")

    if(WITH_HTML_INSTALL)
        install(TARGET "${lang}-${docname}-html"
          DESTINATION "${CMAKE_INSTALL_DOCDIR}/${lang}")
    endif()
endfunction()
