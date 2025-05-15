import { LightningElement, api, wire } from 'lwc';
import 	ckeditorBase from '@salesforce/resourceUrl/ckeditorBase';
import 	ckeditorPremium from '@salesforce/resourceUrl/ckeditorPremium';
import ckeditorBaseCss from '@salesforce/resourceUrl/ckeditorBaseCss';
import ckeditorPremiumCss from '@salesforce/resourceUrl/ckeditorPremiumCss';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import LICENSE_KEY from '@salesforce/label/c.CK_EDITOR_LICENSE_KEY';

export default class ReusableEmailComposer extends LightningElement {

    // Make a Component Aware of Its Record Context
    // https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.use_object_context    
    @api recordId;         // Email Record ID - For new email this will be blank 

    emailEditorInstance;   // To store CKEditor Instance
    emailContent = '';     
    isRenderedCallBackInitialized = false;
    isSpinner = false;
    spinnerText = '';

    async renderedCallback() {
        try{
            if (this.isRenderedCallBackInitialized || this.emailEditorInstance) return;
                this.alreadyRendered = true;
            
                this.spinnerText = 'Please wait while the Email Editor loads...';
                this.isSpinner = true;
                this.isRenderedCallBackInitialized = true;
            await Promise.all(
                [
                    loadScript(this, ckeditorBase)
                    ,loadScript(this, ckeditorPremium)
                    ,loadStyle(this, ckeditorBaseCss)
                    ,loadStyle(this, ckeditorPremiumCss)
                ]
            ).then(() => {
                this.initializeEmailEditor();
                this.spinnerText = '';
                this.isSpinner = false;

            });

        }catch(err){
            this.spinnerText = '';
            this.isSpinner = false;
            console.log (err);
            console.log(JSON.stringify(err));
        }
    }

    initializeEmailEditor(){ 
        try{
            const {
                ClassicEditor,
                Alignment,
                Autoformat,
                AutoImage,
                AutoLink,
                Autosave,
                BlockQuote,
                Bold,
                Bookmark,
                CloudServices,
                Code,
                Emoji,
                Essentials,
                FindAndReplace,
                FontBackgroundColor,
                FontColor,
                FontFamily,
                FontSize,
                GeneralHtmlSupport,
                Heading,
                Highlight,
                HorizontalLine,
                //ImageBlock,
                //ImageCaption,
                ImageEditing,
                ImageInline,
                ImageInsertViaUrl,
                ImageInsert,
                ImageResize,
                ImageStyle,
                ImageTextAlternative,
                ImageToolbar,
                ImageUpload,
                ImageUtils,
                Indent,
                IndentBlock,
                Italic,
                Link,
                List,
                ListProperties,
                Mention,
                PageBreak,
                Paragraph,
                RemoveFormat,
                SpecialCharacters,
                SpecialCharactersArrows,
                SpecialCharactersCurrency,
                SpecialCharactersEssentials,
                SpecialCharactersLatin,
                SpecialCharactersMathematical,
                SpecialCharactersText,
                Strikethrough,
                Style,
                Subscript,
                Superscript,
                Table,
                TableCaption,
                TableCellProperties,
                TableColumnResize,
                TableProperties,
                TableToolbar,
                TextTransformation,
                TodoList,
                Underline
            } = window.CKEDITOR;

            /* TODO: Premium features will be enabled post license */ 
            const {
                //CaseChange,
                //ExportPdf,
                //ExportWord,
                //FormatPainter,
                //ImportWord,
                //MergeFields,
                //MultiLevelList,
                //SlashCommand,
                //TableOfContents,
                //Template
            } = window.CKEDITOR_PREMIUM_FEATURES;
                        
            const editorConfig = {
                toolbar: {
                    items: [
                        'undo', 'redo', '|',
                        /* 'formatPainter', */ 'removeFormat', '|',
                        /* 'caseChange', */ 'subscript', 'superscript', '|',
                        'fontSize', 'fontFamily', 'fontColor', 'fontBackgroundColor', '|',
                        'bold', 'italic', 'underline', 'strikethrough', '|',
                        'alignment', '|',
                        'bulletedList', 'numberedList', /* 'multiLevelList', */ '|',
                        'outdent', 'indent', '|',
                        'link', 'highlight', '|',
                        'blockQuote', 'horizontalLine', 'code', '|',
                        //'heading', 'style', '|',
                        'emoji', 'specialCharacters', '|',
                        'uploadImage', '|',
                        'insertTable', /* 'tableOfContents', */ '|',
                        /*'exportPdf',  'exportWord',  'importWord', '|',*/
                        'findAndReplace', '|',
                        'pageBreak', '|',
                        'bookmark'
                    ],
                    shouldNotGroupWhenFull: true
                },            
                plugins: [
                    Alignment,
                    Autoformat,
                    AutoImage,
                    AutoLink,
                    Autosave,
                    BlockQuote,
                    Bold,
                    Bookmark,
                    CloudServices,
                    Code,
                    Emoji,
                    Essentials,
                    FindAndReplace,
                    FontBackgroundColor,
                    FontColor,
                    FontFamily,
                    FontSize,
                    GeneralHtmlSupport,
                    Heading,
                    Highlight,
                    HorizontalLine,
                    ImageEditing,
                    ImageInline,
                    ImageInsertViaUrl,
                    ImageInsert,
                    ImageResize,
                    ImageStyle,
                    ImageTextAlternative,
                    ImageToolbar,
                    ImageUpload,
                    ImageUtils,
                    Indent,
                    IndentBlock,
                    Italic,
                    Link,
                    List,
                    ListProperties,
                    Mention,
                    PageBreak,
                    Paragraph,
                    RemoveFormat,
                    SpecialCharacters,
                    SpecialCharactersArrows,
                    SpecialCharactersCurrency,
                    SpecialCharactersEssentials,
                    SpecialCharactersLatin,
                    SpecialCharactersMathematical,
                    SpecialCharactersText,
                    Strikethrough,
                    Style,
                    Subscript,
                    Superscript,
                    Table,
                    TableCaption,
                    TableCellProperties,
                    TableColumnResize,
                    TableProperties,
                    TableToolbar,
                    TextTransformation,
                    TodoList,
                    Underline
                ],
                exportPdf: {
                    stylesheets: [
                        /* This path should point to the content stylesheets on your assets server. */
                        /* See: https://ckeditor.com/docs/ckeditor5/latest/features/converters/export-pdf.html */
                        './style.css',
                        /* Export PDF needs access to stylesheets that style the content. */
                        'https://cdn.ckeditor.com/ckeditor5/45.0.0/ckeditor5.css',
                        'https://cdn.ckeditor.com/ckeditor5-premium-features/45.0.0/ckeditor5-premium-features.css'
                    ],
                    fileName: 'export-pdf-demo.pdf',
                    converterOptions: {
                        format: 'Tabloid',
                        margin_top: '20mm',
                        margin_bottom: '20mm',
                        margin_right: '24mm',
                        margin_left: '24mm',
                        page_orientation: 'portrait'
                    }
                },
                exportWord: {
                    stylesheets: [
                        /* This path should point to the content stylesheets on your assets server. */
                        /* See: https://ckeditor.com/docs/ckeditor5/latest/features/converters/export-word.html */
                        './style.css',
                        /* Export Word needs access to stylesheets that style the content. */
                        'https://cdn.ckeditor.com/ckeditor5/45.0.0/ckeditor5.css',
                        'https://cdn.ckeditor.com/ckeditor5-premium-features/45.0.0/ckeditor5-premium-features.css'
                    ],
                    fileName: 'export-word-demo.docx',
                    converterOptions: {
                        document: {
                            orientation: 'portrait',
                            size: 'Tabloid',
                            margins: {
                                top: '20mm',
                                bottom: '20mm',
                                right: '24mm',
                                left: '24mm'
                            }
                        }
                    }
                },
                fontFamily: {
                    supportAllValues: true
                },
                fontSize: {
                    options: [10, 12, 14, 'default', 18, 20, 22],
                    supportAllValues: true
                },
                heading: {
                    options: [
                        {
                            model: 'paragraph',
                            title: 'Paragraph',
                            class: 'ck-heading_paragraph'
                        },
                        {
                            model: 'heading1',
                            view: 'h1',
                            title: 'Heading 1',
                            class: 'ck-heading_heading1'
                        },
                        {
                            model: 'heading2',
                            view: 'h2',
                            title: 'Heading 2',
                            class: 'ck-heading_heading2'
                        },
                        {
                            model: 'heading3',
                            view: 'h3',
                            title: 'Heading 3',
                            class: 'ck-heading_heading3'
                        },
                        {
                            model: 'heading4',
                            view: 'h4',
                            title: 'Heading 4',
                            class: 'ck-heading_heading4'
                        },
                        {
                            model: 'heading5',
                            view: 'h5',
                            title: 'Heading 5',
                            class: 'ck-heading_heading5'
                        },
                        {
                            model: 'heading6',
                            view: 'h6',
                            title: 'Heading 6',
                            class: 'ck-heading_heading6'
                        }
                    ]
                },
                htmlSupport: {
                    allow: [
                        {
                            name: /^.*$/,
                            styles: true,
                            attributes: true,
                            classes: true
                        }
                    ]
                },
                image: {
                    toolbar: ['imageStyle:inline', 'imageStyle:alignLeft', 'imageStyle:alignRight', '|', 'resizeImage'],
                    styles: {
                        options: ['inline', 'alignLeft', 'alignRight']
                    }
                },
                licenseKey: LICENSE_KEY,
                link: {
                    addTargetToExternalLinks: true,
                    defaultProtocol: 'https://',
                    decorators: {
                        toggleDownloadable: {
                            mode: 'manual',
                            label: 'Downloadable',
                            attributes: {
                                download: 'file'
                            }
                        }
                    }
                },
                list: {
                    properties: {
                        styles: true,
                        startIndex: true,
                        reversed: true
                    }
                },
                mention: {
                    feeds: [
                        {
                            marker: '@',
                            feed: [
                            ]
                        }
                    ]
                },
                placeholder: 'Type or paste your content here!',
                style: {
                    definitions: [
                        {
                            name: 'Article category',
                            element: 'h3',
                            classes: ['category']
                        },
                        {
                            name: 'Title',
                            element: 'h2',
                            classes: ['document-title']
                        },
                        {
                            name: 'Subtitle',
                            element: 'h3',
                            classes: ['document-subtitle']
                        },
                        {
                            name: 'Info box',
                            element: 'p',
                            classes: ['info-box']
                        },
                        {
                            name: 'Side quote',
                            element: 'blockquote',
                            classes: ['side-quote']
                        },
                        {
                            name: 'Marker',
                            element: 'span',
                            classes: ['marker']
                        },
                        {
                            name: 'Spoiler',
                            element: 'span',
                            classes: ['spoiler']
                        },
                        {
                            name: 'Code (dark)',
                            element: 'pre',
                            classes: ['fancy-code', 'fancy-code-dark']
                        },
                        {
                            name: 'Code (bright)',
                            element: 'pre',
                            classes: ['fancy-code', 'fancy-code-bright']
                        }
                    ]
                },
                table: {
                    contentToolbar: ['tableColumn', 'tableRow', 'mergeTableCells', 'tableProperties', 'tableCellProperties']
                }
            };

            const emailEditorElement = this.template.querySelector('.emailEditor');

            ClassicEditor.create(emailEditorElement, {
                ...editorConfig,
                initialData: this.emailContent || '', 
            }).then(editor => {
                this.emailEditorInstance = editor;
    
                editor.editing.view.change(writer => {
                    const editableElement = editor.editing.view.document.getRoot();
                    writer.setStyle('min-height', '150px', editableElement);
                });
                
                const model = editor.model;
                const root = model.document.getRoot();
                const positionAtStart = model.createPositionAt(root, 0);
                
                model.change(writer => {
                    writer.setSelection(positionAtStart);
                });
                
                editor.editing.view.focus();
                
            }).catch(error => {
                console.log (err);
                console.log('Error in CK Editor Creation : ' + JSON.stringify(err));
            });

        } catch (err) {
            console.log (err);
            console.log('Error in Initializing the editor : ' + JSON.stringify(err));
        }
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const result = reader.result;
                if (!result) return reject(new Error('FileReader returned null'));
                resolve(result.split(',')[1]);
            };
            reader.onerror = () => reject(new Error('Failed to read file'));
            reader.readAsDataURL(file);
        });
    }
    
}