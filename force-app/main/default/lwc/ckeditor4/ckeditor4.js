import { LightningElement, api, track } from 'lwc';
import CKEDITOR_STATIC from '@salesforce/resourceUrl/CKEditor_4_22_1';

export default class Ckeditor4 extends LightningElement {
  iframeWindow;
  iframeLoaded = false;
  editorReady = false;
  _value = '';

  @api
  set value(content) {
    this._value = content;
    if (this.editorReady) {
      this.setEditorContent(content);
    }
  }
  get value() {
    return this._value;
  }

  @api recordId = '';
  @api toolbarConfig; 

  @api
  focusAtStart() {
    this.iframeWindow?.postMessage({ type: 'focusStart' }, '*');
  }

  get iframeSrc() {
    return CKEDITOR_STATIC + '/ckeditor/ckeditor.html';
  }

  handleIframeLoad() {
    this.iframeWindow = this.template.querySelector('iframe').contentWindow;
    this.iframeWindow.initEditor(this._value, updatedHtml => {
      this._value = updatedHtml;
      this.dispatchEvent(new CustomEvent('passback', {
        detail: { value: updatedHtml }
      }));
    });

    this.editorReady = true;

    window.addEventListener('message', this.handleMessage.bind(this));
  }

  /* handleMessage(event) {
    if (!event?.data?.type) return;

    if (event.data.type === 'change') {
      const newHtml = event.data.value;
      this._value = newHtml;
      this.dispatchEvent(new CustomEvent('passback', {
        detail: { value: newHtml }
      }));
    }
  } */
    handleMessage(event) {
      if (event.data?.type === 'ready') {
        this._value = event.data.payload;
        this.dispatchEvent(new CustomEvent('passback', {
          detail: { value: this._value }
        }));
      }
    }

  @api
  getEditorContent() {
    this.iframeWindow?.postMessage({ type: 'get' }, '*');
  }

  @api
  setEditorContent(newValue) {
    this.iframeWindow?.postMessage({ type: 'set', content: newValue }, '*');
  }

  renderedCallback() {
    if (this.iframeLoaded) return;
    const iframe = this.template.querySelector('iframe');
    if (iframe) {
      iframe.addEventListener('load', this.handleIframeLoad.bind(this));
      this.iframeLoaded = true;
    }
  }

  @api async passBackProcessedData() {
    this.iframeWindow?.postMessage({ type: 'get' }, '*');
  }
}