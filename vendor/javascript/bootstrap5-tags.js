// bootstrap5-tags@1.7.7 downloaded from https://ga.jspm.io/npm:bootstrap5-tags@1.7.7/tags.js

/**
 * Bootstrap 5 (and 4!) tags
 * https://github.com/lekoala/bootstrap5-tags
 * @license MIT
 */
/**
 * @callback EventCallback
 * @param {Event} event
 * @param {Tags} inst
 * @returns {void}
 */
/**
 * @callback ServerCallback
 * @param {Response} response
 * @param {Tags} inst
 * @returns {Promise}
 */
/**
 * @callback ErrorCallback
 * @param {Error} e
 * @param {AbortSignal} signal
 * @param {Tags} inst
 * @returns {void}
 */
/**
 * @callback ModalItemCallback
 * @param {String} value
 * @param {Tags} inst
 * @returns {Promise}
 */
/**
 * @callback RenderCallback
 * @param {Suggestion} item
 * @param {String} label
 * @param {Tags} inst
 * @returns {String}
 */
/**
 * @callback ItemCallback
 * @param {Suggestion} item
 * @param {Tags} inst
 * @returns {void}
 */
/**
 * @callback ValueCallback
 * @param {String} value
 * @param {Tags} inst
 * @returns {void}
 */
/**
 * @callback AddCallback
 * @param {String} value
 * @param {Object} data
 * @param {Tags} inst
 * @returns {void|Boolean}
 */
/**
 * @callback DataCallback
 * @param {*} src
 * @param {Tags} inst
 * @returns {void|Boolean}
 */
/**
 * @callback CreateCallback
 * @param {HTMLOptionElement} option
 * @param {Tags} inst
 * @returns {void}
 */
/**
 * @typedef Config
 * @property {Array<Suggestion|SuggestionGroup>} items Source items
 * @property {Boolean} allowNew Allows creation of new tags
 * @property {Boolean} showAllSuggestions Show all suggestions even if they don't match. Disables validation.
 * @property {String} badgeStyle Color of the badge (color can be configured per option as well)
 * @property {Boolean} allowClear Show a clear icon
 * @property {Boolean} clearEnd Place clear icon at the end
 * @property {Array} selected A list of initially selected values
 * @property {String} regex Regex for new tags
 * @property {Array|String} separator A list (pipe separated) of characters that should act as separator (default is using enter key)
 * @property {Number} max Limit to a maximum of tags (0 = no limit)
 * @property {String} placeholder Provides a placeholder if none are provided as the first empty option
 * @property {String} clearLabel Text as clear tooltip
 * @property {String} searchLabel Default placeholder
 * @property {Boolean} showDropIcon Show dropdown icon
 * @property {Boolean} keepOpen Keep suggestions open after selection, clear on focus out
 * @property {Boolean} allowSame Allow same tags used multiple times
 * @property {String} baseClass Customize the class applied to badges
 * @property {Boolean} addOnBlur Add new tags on blur (only if allowNew is enabled)
 * @property {Boolean} showDisabled Show disabled tags
 * @property {Boolean} hideNativeValidation Hide native validation tooltips
 * @property {Number} suggestionsThreshold Number of chars required to show suggestions
 * @property {Number} maximumItems Maximum number of items to display
 * @property {Boolean} autoselectFirst Always select the first item
 * @property {Boolean} updateOnSelect Update input value on selection (doesn't play nice with autoselectFirst)
 * @property {Boolean} highlightTyped Highlight matched part of the suggestion
 * @property {String} highlightClass Class applied to the mark element
 * @property {Boolean} fullWidth Match the width on the input field
 * @property {Boolean} fixed Use fixed positioning (solve overflow issues)
 * @property {Boolean} fuzzy Fuzzy search
 * @property {Boolean} startsWith Must start with the string. Defaults to false (it matches any position).
 * @property {Boolean} singleBadge Show badge for single elements
 * @property {Array} activeClasses By default: ["bg-primary", "text-white"]
 * @property {String} labelField Key for the label
 * @property {String} valueField Key for the value
 * @property {Array} searchFields Key for the search
 * @property {String} queryParam Name of the param passed to endpoint (query by default)
 * @property {String} server Endpoint for data provider
 * @property {String} serverMethod HTTP request method for data provider, default is GET
 * @property {String|Object} serverParams Parameters to pass along to the server. You can specify a "related" key with the id of a related field.
 * @property {String} serverDataKey By default: data
 * @property {Object} fetchOptions Any other fetch options (https://developer.mozilla.org/en-US/docs/Web/API/fetch#syntax)
 * @property {Boolean} liveServer Should the endpoint be called each time on input
 * @property {Boolean} noCache Prevent caching by appending a timestamp
 * @property {Boolean} allowHtml Allow html in input (can lead to script injection)
 * @property {Function} inputFilter Function to filter input
 * @property {Function} sanitizer Alternative function to sanitize content
 * @property {Number} debounceTime Debounce time for live server
 * @property {String} notFoundMessage Display a no suggestions found message. Leave empty to disable
 * @property {RenderCallback} onRenderItem Callback function that returns the suggestion
 * @property {ItemCallback} onSelectItem Callback function to call on selection
 * @property {ValueCallback} onClearItem Callback function to call on clear
 * @property {CreateCallback} onCreateItem Callback function when an item is created
 * @property {EventCallback} onBlur Callback function on blur
 * @property {DataCallback} onDataLoaded Callback function on data load
 * @property {EventCallback} onFocus Callback function on focus
 * @property {AddCallback} onCanAdd Callback function to validate item. Return false to show validation message.
 * @property {ServerCallback} onServerResponse Callback function to process server response. Must return a Promise
 * @property {ErrorCallback} onServerError Callback function to process server errors.
 * @property {ModalItemCallback} confirmClear Allow modal confirmation of clear. Must return a Promise
 * @property {ModalItemCallback} confirmAdd Allow modal confirmation of add. Must return a Promise
 */
/**
 * @typedef Suggestion
 * @property {String} value Can be overriden by config valueField
 * @property {String} label Can be overriden by config labelField
 * @property {String} title
 * @property {Boolean} disabled
 * @property {Object} data
 * @property {Boolean} [selected]
 * @property {Number} [group_id]
 */
/**
 * @typedef SuggestionGroup
 * @property {String} group
 * @property {Array} items
 */
/**
 * @type {Config}
 */
const e={items:[],allowNew:false,showAllSuggestions:false,badgeStyle:"primary",allowClear:false,clearEnd:false,selected:[],regex:"",separator:[],max:0,clearLabel:"Clear",searchLabel:"Type a value",showDropIcon:true,keepOpen:false,allowSame:false,baseClass:"",placeholder:"",addOnBlur:false,showDisabled:false,hideNativeValidation:false,suggestionsThreshold:-1,maximumItems:0,autoselectFirst:true,updateOnSelect:false,highlightTyped:false,highlightClass:"",fullWidth:true,fixed:false,fuzzy:false,startsWith:false,singleBadge:false,activeClasses:["bg-primary","text-white"],labelField:"label",valueField:"value",searchFields:["label"],queryParam:"query",server:"",serverMethod:"GET",serverParams:{},serverDataKey:"data",fetchOptions:{},liveServer:false,noCache:true,allowHtml:false,debounceTime:300,notFoundMessage:"",inputFilter:e=>e,sanitizer:e=>sanitize(e),onRenderItem:(e,t,s)=>s.config("allowHtml")?t:s.config("sanitizer")(t),onSelectItem:(e,t)=>{},onClearItem:(e,t)=>{},onCreateItem:(e,t)=>{},onBlur:(e,t)=>{},onDataLoaded:(e,t)=>{},onFocus:(e,t)=>{},onCanAdd:(e,t,s)=>{},confirmClear:(e,t)=>Promise.resolve(),confirmAdd:(e,t)=>Promise.resolve(),onServerResponse:(e,t)=>e.json(),onServerError:(e,t,s)=>{e.name==="AbortError"||t.aborted||console.error(e)}};const t="tags-";const s="is-loading";const i="is-active";const n="is-invalid";const l="is-max-reached";const o="show";const r="data-value";const a="next";const h="prev";const c="form-control-focus";const d="form-placeholder-shown";const u="form-control-disabled";const f=new WeakMap;let _=0;let g=window.bootstrap&&window.bootstrap.Tooltip;
/**
 * @param {Function} func
 * @param {number} timeout
 * @returns {Function}
 */function debounce(e,t=300){let s;return(...i)=>{clearTimeout(s);s=setTimeout((()=>{e.apply(this,i)}),t)}}
/**
 * @param {string} text
 * @param {string} size
 * @returns {Number}
 */function calcTextWidth(e,t=null){const s=ce("span");document.body.appendChild(s);s.style.fontSize=t||"inherit";s.style.height="auto";s.style.width="auto";s.style.position="absolute";s.style.whiteSpace="no-wrap";s.innerHTML=sanitize(e);const i=Math.ceil(s.clientWidth);document.body.removeChild(s);return i}
/**
 * @link https://stackoverflow.com/questions/3043775/how-to-escape-html
 * @param {string} text
 * @returns {string}
 */function sanitize(e){return e.replace(/[\x26\x0A\<>'"]/g,(function(e){return"&#"+e.charCodeAt(0)+";"}))}
/**
 * @param {String} str
 * @returns {String}
 */function removeDiacritics(e){return e.normalize("NFD").replace(/[\u0300-\u036f]/g,"")}
/**
 * @param {String|Number} str
 * @returns {String}
 */function normalize(e){return e?removeDiacritics(e.toString()).toLowerCase():""}
/**
 * A simple fuzzy match algorithm that checks if chars are matched
 * in order in the target string
 *
 * @param {String} str
 * @param {String} lookup
 * @returns {Boolean}
 */function fuzzyMatch(e,t){if(e.indexOf(t)>=0)return true;let s=0;for(let i=0;i<t.length;i++){const n=t[i];if(n!=" "){s=e.indexOf(n,s)+1;if(s<=0)return false}}return true}
/**
 * @param {HTMLElement} item
 */function hideItem(e){e.style.display="none";attrs(e,{"aria-hidden":"true"})}
/**
 * @param {HTMLElement} item
 */function showItem(e){e.style.display="list-item";attrs(e,{"aria-hidden":"false"})}
/**
 * @param {HTMLElement} el
 * @param {Object} attrs
 */function attrs(e,t){for(const[s,i]of Object.entries(t))e.setAttribute(s,i)}
/**
 * @param {HTMLElement} el
 * @param {string} attr
 */function rmAttr(e,t){e.hasAttribute(t)&&e.removeAttribute(t)}
/**
 * Allow 1/0, true/false as strings
 * @param {any} value
 * @returns {Boolean}
 */function parseBool(e){return["true","false","1","0",true,false].includes(e)&&!!JSON.parse(e)}
/**
 * @template {keyof HTMLElementTagNameMap} K
 * @param {K|String} tagName Name of the element
 * @returns {*}
 */function ce(e){return document.createElement(e)}
/**
 *
 * @param {String} str
 * @param {Array} tokens
 * @returns {Array}
 */function splitMulti(e,t){let s=t[0];for(let i=1;i<t.length;i++)e=e.split(t[i]).join(s);return e.split(s)}function nested(e,t="window"){return e.split(".").reduce(((e,t)=>e[t]),t)}
/**
 * @param {HTMLElement} el
 * @param {HTMLElement} newEl
 * @returns {HTMLElement}
 */class Tags{
/**
	 * @param {HTMLSelectElement} el
	 * @param {Object|Config} config
	 */
constructor(e,t={}){if(e instanceof HTMLElement){f.set(e,this);_++;this._selectElement=e;this._configure(t);this._isMouse=false;this._keyboardNavigation=false;this._searchFunc=debounce((()=>{this._loadFromServer(true)}),this._config.debounceTime);this._fireEvents=true;this._configureParent();this._holderElement=ce("div");this._containerElement=ce("div");this._dropElement=ce("ul");this._searchInput=ce("input");this._holderElement.appendChild(this._containerElement);this._selectElement.parentElement.insertBefore(this._holderElement,this._selectElement);this._configureHolderElement();this._configureContainerElement();this._configureSelectElement();this._configureSearchInput();this._configureDropElement();this.resetState();this.handleEvent=e=>{this._handleEvent(e)};if(this._config.fixed){document.addEventListener("scroll",this,true);window.addEventListener("resize",this)}["focus","blur","input","keydown","paste"].forEach((e=>{this._searchInput.addEventListener(e,this)}));["mousemove","mouseleave"].forEach((e=>{this._dropElement.addEventListener(e,this)}));this.loadData(true)}else console.error("Invalid element",e)}
/**
	 * Attach to all elements matched by the selector
	 * @param {string} selector
	 * @param {Object} opts
	 * @param {Boolean} reset
	 */
static init(e="select[multiple]",t={},s=false){
/**
		 * @type {NodeListOf<HTMLSelectElement>}
		 */
let i=document.querySelectorAll(e);for(let e=0;e<i.length;e++){const n=Tags.getInstance(i[e]);if(!n||s){n&&n.dispose();new Tags(i[e],t)}}}
/**
	 * @param {HTMLSelectElement} el
	 */static getInstance(e){if(f.has(e))return f.get(e)}dispose(){["focus","blur","input","keydown","paste"].forEach((e=>{this._searchInput.removeEventListener(e,this)}));["mousemove","mouseleave"].forEach((e=>{this._dropElement.removeEventListener(e,this)}));if(this._config.fixed){document.removeEventListener("scroll",this,true);window.removeEventListener("resize",this)}this._selectElement.style.display="block";this._holderElement.parentElement.removeChild(this._holderElement);this.parentForm&&this.parentForm.removeEventListener("reset",this);f.delete(this._selectElement)}
/**
	 * event-polyfill compat / handleEvent is expected on class
	 * @link https://github.com/lifaon74/events-polyfill/issues/10
	 * @param {Event} event
	 */handleEvent(e){this._handleEvent(e)}
/**
	 * @link https://gist.github.com/WebReflection/ec9f6687842aa385477c4afca625bbf4#handling-events
	 * @param {Event} event
	 */_handleEvent(e){const t=["scroll","resize"];if(t.includes(e.type)){this._timer&&window.cancelAnimationFrame(this._timer);this._timer=window.requestAnimationFrame((()=>{this[`on${e.type}`](e)}))}else this[`on${e.type}`](e)}
/**
	 * @param {Config|Object} config
	 */_configure(t={}){this._config=Object.assign({},e,{showDropIcon:!!this._findOption()});const s=this._selectElement.dataset.config?JSON.parse(this._selectElement.dataset.config):{};const i={...t,...s,...this._selectElement.dataset};for(const[t,s]of Object.entries(e)){if(t=="config"||i[t]===void 0)continue;const e=i[t];switch(typeof s){case"number":this._config[t]=parseInt(e);break;case"boolean":this._config[t]=parseBool(e);break;case"string":this._config[t]=e.toString();break;case"object":this._config[t]=e;typeof e==="string"&&(["{","["].includes(e[0])?this._config[t]=JSON.parse(e):this._config[t]=e.split(e.includes("|")?"|":","));break;case"function":this._config[t]=typeof e==="string"?e.split(".").reduce(((e,t)=>e[t]),window):e;this._config[t]||console.error("Invalid function",e);break;default:this._config[t]=e;break}}this._config.placeholder||(this._config.placeholder=this._getPlaceholder());this._config.suggestionsThreshold==-1&&(this._config.suggestionsThreshold=this._config.liveServer?1:0)}
/**
	 * @param {String} k
	 * @returns {*}
	 */config(e=null){return e?this._config[e]:this._config}
/**
	 * @param {String} k
	 * @param {*} v
	 */setConfig(e,t){this._config[e]=t}_configureParent(){this.overflowParent=null;this.parentForm=this._selectElement.parentElement;while(this.parentForm){this.parentForm.style.overflow==="hidden"&&(this.overflowParent=this.parentForm);this.parentForm=this.parentForm.parentElement;if(this.parentForm&&this.parentForm.nodeName=="FORM")break}this.parentForm&&this.parentForm.addEventListener("reset",this)}
/**
	 * @returns {string}
	 */_getPlaceholder(){if(this._selectElement.hasAttribute("placeholder"))return this._selectElement.getAttribute("placeholder");if(this._selectElement.dataset.placeholder)return this._selectElement.dataset.placeholder;let e=this._selectElement.querySelector("option");if(!e||!this._config.autoselectFirst)return"";rmAttr(e,"selected");e.selected=false;return e.value?"":e.textContent}_configureSelectElement(){const e=this._selectElement;if(this._config.hideNativeValidation){e.style.position="absolute";e.style.left="-9999px"}else e.style.cssText="height:1px;width:1px;opacity:0;padding:0;margin:0;border:0;float:left;flex-basis:100%;min-height:unset;";e.tabIndex=-1;e.addEventListener("focus",(e=>{this.onclick(e)}));e.addEventListener("invalid",(e=>{this._holderElement.classList.add(n)}))}_configureDropElement(){const e=this._dropElement;e.classList.add("dropdown-menu",t+"menu");e.id=t+"menu-"+_;e.setAttribute("role","menu");const s=e.style;s.padding="0";s.maxHeight="280px";this._config.fullWidth||(s.maxWidth="360px");this._config.fixed&&(s.position="fixed");s.overflowY="auto";s.overscrollBehavior="contain";s.textAlign="unset";e.addEventListener("mouseenter",(e=>{this._keyboardNavigation=false}));this._holderElement.appendChild(e);this._searchInput.setAttribute("aria-controls",e.id)}_configureHolderElement(){const e=this._holderElement;e.classList.add("form-control","dropdown");["form-select-lg","form-select-sm","is-invalid","is-valid"].forEach((t=>{this._selectElement.classList.contains(t)&&e.classList.add(t)}));this._config.suggestionsThreshold==0&&this._config.showDropIcon&&e.classList.add("form-select");this.overflowParent&&(e.style.position="inherit");e.style.height="auto";e.addEventListener("click",this)}_configureContainerElement(){this._containerElement.addEventListener("click",(e=>{this.isDisabled()||this._searchInput.style.visibility!="hidden"&&this._searchInput.focus()}));const e=this._containerElement.style;e.display="flex";e.alignItems="center";e.flexWrap="wrap"}_configureSearchInput(){const e=this._searchInput;e.type="text";e.autocomplete="off";e.spellcheck=false;attrs(e,{"aria-autocomplete":"list","aria-haspopup":"menu","aria-expanded":"false","aria-label":this._config.searchLabel,role:"combobox"});e.style.cssText="background-color:transparent;color:currentColor;border:0;padding:0;outline:0;max-width:100%";this.resetSearchInput(true);this._containerElement.appendChild(e);this._rtl=window.getComputedStyle(e).direction==="rtl"}onfocus(e){if(!this._holderElement.classList.contains(c)){this._holderElement.classList.add(c);this.showOrSearch();this._config.onFocus(e,this)}}onblur(e){const s=e.relatedTarget;this._isMouse&&s&&(s.classList.contains("modal")||s.classList.contains(t+"menu"))?this._searchInput.focus():this.afteronblur(e)}
/**
	 * This is triggered externally by a document click handler
	 * Scrolling in the suggestion triggers the blur event and will close the suggestion
	 * so we cannot rely on the blur event of the input element
	 * We check for click and focus events (click when clicking outside, focus when tabbing...)
	 * @param {Event} event
	 */afteronblur(e){this._abortController&&this._abortController.abort();let t=true;this._config.addOnBlur&&this._searchInput.value&&(t=this._enterValue());this._holderElement.classList.remove(c);this.hideSuggestions(t);if(this._fireEvents){const t=this.getSelection();const s={selection:t?t.dataset.value:null,input:this._searchInput.value};this._config.onBlur(e,this);this._selectElement.dispatchEvent(new CustomEvent("tags.blur",{bubbles:true,detail:s}))}}onpaste(e){const t=e.clipboardData||window.clipboardData;const s=t.getData("text/plain").replace(/\r\n|\n/g," ");if(s.length>2&&this._config.separator.length){const t=splitMulti(s,this._config.separator).filter((e=>e));if(t.length>1){e.preventDefault();t.forEach((e=>{this._addPastedValue(e)}))}}}_addPastedValue(e){let t=e;let s={};if(this._config.allowNew)s.new=1;else{const s=this.getSelection();if(!s)return;e=s.getAttribute(r);t=s.dataset.label}this._config.confirmAdd(e,this).then((()=>{this._add(t,e,s)})).catch((()=>{}))}oninput(e){const t=this._config.inputFilter(this._searchInput.value);t!=this._searchInput.value&&(this._searchInput.value=t);if(t){const e=t.slice(-1);if(this._config.separator.length&&this._config.separator.includes(e)){this._searchInput.value=this._searchInput.value.slice(0,-1);let e=this._searchInput.value;this._addPastedValue(e);return}}setTimeout((()=>{this._adjustWidth()}));this.showOrSearch()}
/**
	 * keypress doesn't send arrow keys, so we use keydown
	 * @param {KeyboardEvent} event
	 */onkeydown(e){let t=e.keyCode||e.key;
/**
		 * @type {HTMLInputElement}
		 */const s=e.target;e.keyCode==229&&(t=s.value.charAt(s.selectionStart-1).charCodeAt(0));switch(t){case 13:case"Enter":e.preventDefault();this._enterValue();break;case 38:case"ArrowUp":e.preventDefault();this._keyboardNavigation=true;this._moveSelection(h);break;case 40:case"ArrowDown":e.preventDefault();this._keyboardNavigation=true;this.isDropdownVisible()?this._moveSelection(a):this.showOrSearch(false);break;case 8:case"Backspace":const t=this.getLastItem();this._searchInput.value.length==0&&t&&this._config.confirmClear(t,this).then((()=>{this.removeLastItem();this._adjustWidth();this.showOrSearch()})).catch((()=>{}));break;case 27:case"Escape":this._searchInput.focus();this.hideSuggestions();break}}onmousemove(e){this._isMouse=true;this._keyboardNavigation=false}onmouseleave(e){this._isMouse=false;this.removeSelection()}onscroll(e){this._positionMenu()}onresize(e){this._positionMenu()}onclick(e=null){!this.isSingle()&&this.isMaxReached()||this._searchInput.focus()}onreset(e){this.reset()}
/**
	 * @param {Boolean} init called during init
	 */
loadData(e=false){Object.keys(this._config.items).length>0?this.setData(this._config.items,true):this.resetSuggestions(true);this._config.server&&(this._config.liveServer||this._loadFromServer(!e))}_setSelectedAttributes(){const e=this._selectElement.selectedOptions||[];for(let t=0;t<e.length;t++)e[t].value&&!e[t].hasAttribute("selected")&&e[t].setAttribute("selected","selected")}resetState(){if(this.isDisabled()){this._holderElement.setAttribute("readonly","");this._searchInput.setAttribute("disabled","");this._holderElement.classList.add(u)}else{rmAttr(this._holderElement,"readonly");rmAttr(this._searchInput,"disabled");this._holderElement.classList.remove(u)}}
/**
	 * Reset suggestions from select element
	 * Iterates over option children then calls setData
	 * @param {Boolean} init called during init
	 */resetSuggestions(e=false){this._setSelectedAttributes();const convertOption=e=>({value:e.getAttribute("value"),label:e.textContent,disabled:e.disabled,selected:e.selected,title:e.title,data:Object.assign({disabled:e.disabled},e.dataset)});let t=Array.from(this._selectElement.children).filter((
/**
				 * @param {HTMLOptionElement|HTMLOptGroupElement} option
				 */
e=>e.hasAttribute("label")||!e.disabled||this._config.showDisabled)).map((
/**
				 * @param {HTMLOptionElement|HTMLOptGroupElement} option
				 */
e=>e.hasAttribute("label")?{group:e.getAttribute("label"),items:Array.from(e.children).map((e=>convertOption(e)))}:convertOption(e)));this.setData(t,e)}
/**
	 * Try to add the current value
	 * @returns {Boolean}
	 */_enterValue(){let e=this.getSelection();if(e){e.click();return true}if(this._config.allowNew&&this._searchInput.value){let e=this._searchInput.value;this._config.confirmAdd(e,this).then((()=>{this._add(e,e,{new:1})})).catch((()=>{}));return true}return false}
/**
	 * @param {Boolean} show Show menu after load. False during init
	 */_loadFromServer(e=false){this._abortController&&this._abortController.abort();this._abortController=new AbortController;let t=this._selectElement.dataset.serverParams||{};typeof t=="string"&&(t=JSON.parse(t));const i=Object.assign({},this._config.serverParams,t);i[this._config.queryParam]=this._searchInput.value;this._config.noCache&&(i.t=Date.now());if(i.related){
/**
			 * @type {HTMLInputElement}
			 */
const e=document.getElementById(i.related);if(e){i.related=e.value;const t=e.getAttribute("name");t&&(i[t]=e.value)}}const n=new URLSearchParams(i);let l=this._config.server;let o=Object.assign(this._config.fetchOptions,{method:this._config.serverMethod||"GET",signal:this._abortController.signal});o.method==="POST"?o.body=n:l+="?"+n.toString();this._holderElement.classList.add(s);fetch(l,o).then((e=>this._config.onServerResponse(e,this))).then((t=>{const s=nested(this._config.serverDataKey,t)||t;this.setData(s,!e);this._abortController=null;e&&this._showSuggestions()})).catch((e=>{this._config.onServerError(e,this._abortController.signal,this)})).finally((e=>{this._holderElement.classList.remove(s)}))}
/**
	 * Wrapper for the public addItem method that check if the item
	 * can be added
	 *
	 * @param {string} text
	 * @param {string} value
	 * @param {object} data
	 * @returns {HTMLOptionElement|null}
	 */_add(e,t=null,s={}){!s.value&&t&&(s.value=t);if(!this.canAdd(e,s))return null;const i=this.addItem(e,t,s);this._resetHtmlState();this._config.keepOpen?this._showSuggestions():this.resetSearchInput();return i}
/**
	 * @param {HTMLElement} li
	 * @returns {Boolean}
	 */_isItemEnabled(e){if(e.style.display==="none")return false;const t=e.firstElementChild;return t.tagName==="A"&&!t.classList.contains("disabled")}
/**
	 * @param {String} dir
	 * @param {*|HTMLElement} sel
	 * @returns {HTMLElement}
	 */_moveSelection(e=a,t=null){const s=this.getSelection();if(s){const i=e===a?"nextSibling":"previousSibling";t=s.parentNode;do{t=t[i]}while(t&&!this._isItemEnabled(t));t?s.classList.remove(...this._activeClasses()):s&&(t=s.parentElement)}else{if(e===h)return t;if(!t){t=this._dropElement.firstChild;while(t&&!this._isItemEnabled(t))t=t.nextSibling}}if(t){const s=t.offsetHeight;const i=t.offsetTop;const n=t.parentNode;const l=n.offsetHeight;const o=n.scrollHeight;const r=n.offsetTop;s===0&&setTimeout((()=>{n.scrollTop=0}));if(e===h){const e=i-r>10?i-r:0;n.scrollTop=e}else{const e=i+s-(l+n.scrollTop);if(e>0&&s>0){n.scrollTop=i+s-l+1;n.scrollTop+l>=o-10&&(n.scrollTop=i-r)}}const a=t.querySelector("a");a.classList.add(...this._activeClasses());this._searchInput.setAttribute("aria-activedescendant",a.id);if(this._config.updateOnSelect){this._searchInput.value=a.dataset.label;this._adjustWidth()}}else this._searchInput.setAttribute("aria-activedescendant","");return t}_adjustWidth(){this._holderElement.classList.remove(d);if(this._searchInput.value)this._searchInput.size=this._searchInput.value.length;else if(this.getSelectedValues().length){this._searchInput.placeholder="";this._searchInput.size=1}else{this._searchInput.size=this._config.placeholder.length>0?this._config.placeholder.length:1;this._searchInput.placeholder=this._config.placeholder;this._holderElement.classList.add(d)}const e=this._searchInput.value||this._searchInput.placeholder;const t=window.getComputedStyle(this._holderElement).fontSize;const s=calcTextWidth(e,t)+16;this._searchInput.style.width=s+"px"}
/**
	 * Add suggestions to the drop element
	 * @param {Array<Suggestion|SuggestionGroup>} suggestions
	 */_buildSuggestions(e){while(this._dropElement.lastChild)this._dropElement.removeChild(this._dropElement.lastChild);let s=0;let i=1;for(let t=0;t<e.length;t++){const n=e[t];if(n){if(n.group&&n.items){const e=ce("li");e.setAttribute("role","presentation");e.dataset.id=""+i;const t=ce("span");e.append(t);t.classList.add("dropdown-header","text-truncate");t.innerHTML=this._config.sanitizer(n.group);this._dropElement.appendChild(e);if(n.items)for(let e=0;e<n.items.length;e++){const t=n.items[e];t.group_id=i;this._buildSuggestionsItem(n.items[e],s);s++}i++}this._buildSuggestionsItem(n,s);s++}}if(this._config.notFoundMessage){const e=ce("li");e.setAttribute("role","presentation");e.classList.add(t+"not-found");e.innerHTML='<span class="dropdown-item"></span>';this._dropElement.appendChild(e)}}
/**
	 * @param {Suggestion} suggestion
	 * @param {Number} i The global counter
	 */_buildSuggestionsItem(e,t){if(!e[this._config.valueField])return;const s=e[this._config.valueField];const i=e[this._config.labelField];let n=this._config.onRenderItem(e,i,this);const l=ce("li");l.setAttribute("role","menuitem");e.group_id&&l.setAttribute("data-group-id",""+e.group_id);if(e.title){l.setAttribute("title",e.title);l.setAttribute("data-bs-placement","left")}const o=ce("a");l.append(o);o.id=this._dropElement.id+"-"+t;o.classList.add("dropdown-item","text-truncate");e.disabled&&o.classList.add("disabled");o.setAttribute(r,s);o.dataset.label=i;const a={};this._config.searchFields.forEach((t=>{a[t]=e[t]}));o.dataset.searchData=JSON.stringify(a);o.setAttribute("href","#");o.innerHTML=n;this._dropElement.appendChild(l);const h=this._getBootstrapVersion()===5;e.title&&g&&h&&g.getOrCreateInstance(l);o.addEventListener("mouseenter",(e=>{if(!this._keyboardNavigation){this.removeSelection();l.querySelector("a").classList.add(...this._activeClasses())}}));o.addEventListener("mousedown",(e=>{e.preventDefault()}));o.addEventListener("click",(t=>{t.preventDefault();t.stopPropagation();this._config.confirmAdd(s,this).then((()=>{this._add(i,s,e.data);this._config.onSelectItem(e,this)})).catch((()=>{}))}))}
/**
	 * @returns {NodeListOf<HTMLOptionElement>}
	 */initialOptions(){return this._selectElement.querySelectorAll("option[data-init]")}_removeSelectedAttrs(){this._selectElement.querySelectorAll("option").forEach((e=>{rmAttr(e,"selected")}))}reset(){this.removeAll();this._fireEvents=false;const e=this.initialOptions();this._removeSelectedAttrs();for(let t=0;t<e.length;t++){const s=e[t];const i=Object.assign({},{disabled:s.hasAttribute("disabled")},s.dataset);this.addItem(s.textContent,s.value,i)}this._resetHtmlState();this._fireEvents=true}
/**
	 * @param {Boolean} init Pass true during init
	 */resetSearchInput(e=false){this._searchInput.value="";this._adjustWidth();this._checkMax();if(!this.isSingle()||e){if(!e){this._shouldShow()||this.hideSuggestions();this._searchInput===document.activeElement&&this._searchInput.dispatchEvent(new Event("input"))}}else{document.activeElement.blur();this.hideSuggestions()}}_checkMax(){if(this.isMaxReached()){this._holderElement.classList.add(l);this._searchInput.style.visibility="hidden"}else this._searchInput.style.visibility=="hidden"&&(this._searchInput.style.visibility="visible")}
/**
	 * @returns {Array}
	 */getSelectedValues(){
/**
		 * @type {NodeListOf<HTMLOptionElement>}
		 */
const e=this._selectElement.querySelectorAll("option[selected]");return Array.from(e).map((e=>e.value))}
/**
	 * @returns {Array}
	 */getAvailableValues(){
/**
		 * @type {NodeListOf<HTMLOptionElement>}
		 */
const e=this._selectElement.querySelectorAll("option");return Array.from(e).map((e=>e.value))}
/**
	 * Show suggestions or search them depending on live server
	 * @param {Boolean} check
	 */showOrSearch(e=true){!e||this._shouldShow()?this._config.liveServer?this._searchFunc():this._showSuggestions():this.hideSuggestions(false)}
/**
	 * The element create with buildSuggestions
	 * @param {Boolean} clearValidation
	 */hideSuggestions(e=true){this._dropElement.classList.remove(o);attrs(this._searchInput,{"aria-expanded":"false"});this.removeSelection();e&&this._holderElement.classList.remove(n)}
/**
	 * Show or hide suggestions
	 * @param {Boolean} check Show suggestions regardless if shouldShow conditions
	 * @param {Boolean} clearValidation
	 */toggleSuggestions(e=true,t=true){this._dropElement.classList.contains(o)?this.hideSuggestions(t):this.showOrSearch(e)}
/**
	 * Do we have enough input to show suggestions ?
	 * @returns {Boolean}
	 */_shouldShow(){return!this.isDisabled()&&!this.isMaxReached()&&this._searchInput.value.length>=this._config.suggestionsThreshold}_showSuggestions(){if(this._searchInput.style.visibility=="hidden")return;const e=normalize(this._searchInput.value);const s={};const i=this._dropElement.querySelectorAll("li");let l=0;let o=null;let h=false;let c={};for(let t=0;t<i.length;t++){
/**
			 * @type {HTMLLIElement}
			 */
let n=i[t];
/**
			 * @type {HTMLAnchorElement|HTMLSpanElement}
			 */let a=n.firstElementChild;if(a instanceof HTMLSpanElement){n.dataset.id&&(c[n.dataset.id]=false);hideItem(n);continue}a.classList.remove(...this._activeClasses());if(!this._config.allowSame){const e=a.getAttribute(r);s[e]=s[e]||0;const t=this._findOption(a.getAttribute(r),"[selected]",s[e]++);if(t){hideItem(n);continue}}const d=this._config.showAllSuggestions||e.length===0;let u=e.length==0&&this._config.suggestionsThreshold===0;if(!d&&e.length>0){const t=JSON.parse(a.dataset.searchData);this._config.searchFields.forEach((s=>{const i=normalize(t[s]);let n=false;if(this._config.fuzzy)n=fuzzyMatch(i,e);else{const t=i.indexOf(e);n=this._config.startsWith?t===0:t>=0}n&&(u=true)}))}const f=u||e.length===0;if(d||u){l++;showItem(n);n.dataset.groupId&&(c[n.dataset.groupId]=true);!o&&this._isItemEnabled(n)&&f&&(o=n);this._config.maximumItems>0&&l>this._config.maximumItems&&hideItem(n)}else hideItem(n);if(this._config.highlightTyped){const t=a.textContent;const s=normalize(t).indexOf(e);const i=t.substring(0,s)+`<mark class="${this._config.highlightClass}">${t.substring(s,s+e.length)}</mark>`+t.substring(s+e.length,t.length);a.innerHTML=i}this._isItemEnabled(n)&&(h=true)}this._config.allowNew||e.length===0&&!h||this._holderElement.classList.add(n);this._config.allowNew&&this._config.regex&&this.isInvalid()&&this._holderElement.classList.remove(n);Array.from(i).filter((e=>e.dataset.id)).forEach((e=>{c[e.dataset.id]===true&&showItem(e)}));if(h){this._holderElement.classList.remove(n);if(o&&this._config.autoselectFirst){this.removeSelection();this._moveSelection(a,o)}}if(l===0)if(this._config.notFoundMessage){
/**
				 * @type {HTMLElement}
				 */
const e=this._dropElement.querySelector("."+t+"not-found");e.style.display="block";const s=this._config.notFoundMessage.replace("{{tag}}",this._searchInput.value);e.innerHTML=`<span class="dropdown-item">${s}</span>`;this._showDropdown()}else this.hideSuggestions(false);else this._showDropdown()}_showDropdown(){const e=this._dropElement.classList.contains(o);if(!e){this._dropElement.classList.add(o);attrs(this._searchInput,{"aria-expanded":"true"})}this._positionMenu(e)}
/**
	 * @param {Boolean} wasVisible
	 */_positionMenu(e=false){const t=this._rtl;const s=this._config.fixed;const i=this._config.fullWidth;const n=this._searchInput.getBoundingClientRect();const l=this._holderElement.getBoundingClientRect();let o=0;let r=0;if(s)if(i){o=l.x;r=l.y+l.height+2}else{o=n.x;r=n.y+n.height}else if(i){o=0;r=l.height+2}else{o=this._searchInput.offsetLeft;r=this._searchInput.offsetHeight+this._searchInput.offsetTop}t&&!i&&(o-=this._dropElement.offsetWidth-n.width);if(!i){const e=Math.min(window.innerWidth,document.body.offsetWidth);const s=t?n.x+n.width-this._dropElement.offsetWidth-1:e-1-(n.x+this._dropElement.offsetWidth);s<0&&(o=t?o-s:o+s)}i&&(this._dropElement.style.width=this._holderElement.offsetWidth+"px");e||(this._dropElement.style.transform="unset");Object.assign(this._dropElement.style,{left:o+"px",top:r+"px"});const a=this._dropElement.getBoundingClientRect();const h=window.innerHeight;if(a.y+a.height>h||this._dropElement.style.transform.includes("translateY")){const e=i?l.height+4:n.height;this._dropElement.style.transform="translateY(calc(-100.1% - "+e+"px))"}}
/**
	 * @returns {Number}
	 */_getBootstrapVersion(){let e=5;let t=window.jQuery;t&&t.fn.tooltip&&t.fn.tooltip.Constructor&&(e=parseInt(t.fn.tooltip.Constructor.VERSION.charAt(0)));return e}
/**
	 * Find if label is already selected (based on attribute)
	 * @param {string} text
	 * @returns {Boolean}
	 */_isSelected(e){const t=Array.from(this._selectElement.querySelectorAll("option"));const s=t.find((t=>t.textContent==e&&t.getAttribute("selected")));return!!s}
/**
	 * Find if label is already selectable (based on attribute)
	 * @param {string} text
	 * @param {Object} data
	 * @returns {Boolean}
	 */_isSelectable(e,t){const s=Array.from(this._selectElement.querySelectorAll("option"));const i=t.value?s.filter((e=>e.value==t.value)):s.filter((t=>t.textContent==e));if(i.length>0){const e=i.find((e=>!e.getAttribute("selected")));if(!e)return false}return true}
/**
	 * Find if label is selectable (based on attribute)
	 * @param {string} text
	 * @returns {Boolean}
	 */hasItem(e){for(let t of this._config.items){const s=t.items||[t];for(let t of s)if(t[this._config.labelField]==e)return true}return false}
/**
	 * @param {string} value
	 * @returns {Object|null}
	 */getItem(e){for(let t of this._config.items){const s=t.items||[t];for(let t of s)if(t[this._config.valueField]==e)return t}return null}
/**
	 * Checks if value matches a configured regex
	 * @param {string} value
	 * @returns {Boolean}
	 */_validateRegex(e){const t=new RegExp(this._config.regex.trim());return t.test(e)}
/**
	 * @returns {HTMLElement}
	 */getSelection(){return this._dropElement.querySelector("a."+i)}removeSelection(){const e=this.getSelection();e&&e.classList.remove(...this._activeClasses())}
/**
	 * @returns {Array}
	 */_activeClasses(){return[...this._config.activeClasses,i]}
/**
	 * @deprecated since 1.5
	 * @returns {HTMLElement}
	 */getActiveSelection(){return this.getSelection()}
/**
	 * @deprecated since 1.5
	 */removeActiveSelection(){return this.removeSelection()}removeAll(){let e=this.getSelectedValues();e.forEach((e=>{this.removeItem(e,true)}));this._adjustWidth()}
/**
	 * @param {Boolean} noEvents
	 */removeLastItem(e=false){let t=this.getLastItem();t&&this.removeItem(t,e)}getLastItem(){let e=this._containerElement.querySelectorAll("span."+t+"badge");if(!e.length)return;let s=e[e.length-1];return s.getAttribute(r)}enable(){this._selectElement.setAttribute("disabled","");this.resetState()}disable(){rmAttr(this._selectElement,"disabled");this.resetState()}
/**
	 * @returns {Boolean}
	 */isDisabled(){return this._selectElement.hasAttribute("disabled")||this._selectElement.disabled||this._selectElement.hasAttribute("readonly")}
/**
	 * @returns {Boolean}
	 */isDropdownVisible(){return this._dropElement.classList.contains(o)}
/**
	 * @returns {Boolean}
	 */isInvalid(){return this._holderElement.classList.contains(n)}
/**
	 * @returns {Boolean}
	 */isSingle(){return!this._selectElement.hasAttribute("multiple")}
/**
	 * @returns {Boolean}
	 */isMaxReached(){return this._config.max&&this.getSelectedValues().length>=this._config.max}
/**
	 * @param {string} text
	 * @param {Object} data
	 * @returns {Boolean}
	 */canAdd(e,t={}){if(!e)return false;if(t.new&&!this._config.allowNew)return false;if(!t.new&&!this.hasItem(e))return false;if(this.isDisabled())return false;if(!this.isSingle()&&!this._config.allowSame)if(t.new){if(this._isSelected(e))return false}else if(!this._isSelectable(e,t))return false;if(this.isMaxReached())return false;if(this._config.regex&&t.new&&!this._validateRegex(e)){this._holderElement.classList.add(n);return false}if(this._config.onCanAdd&&this._config.onCanAdd(e,t,this)===false){this._holderElement.classList.add(n);return false}return true}getData(){return this._config.items}
/**
	 * Set data
	 * @param {Array<Suggestion|SuggestionGroup>|Object} src An array of items or a value:label object
	 * @param {Boolean} init called during init
	 */setData(e,t=false){this._fireEvents=false;Array.isArray(e)||(e=Object.entries(e).map((([e,t])=>({value:e,label:t}))));this._config.items!=e&&(this._config.items=e);if(t){this._removeSelectedAttrs();const t=e.reduce(((e,t)=>e.concat(t.group?t.items:[t])),[]);t.forEach((e=>{const t=e[this._config.valueField];const s=e[this._config.labelField];if(t&&(e.selected||this._config.selected.includes(t))){const i=this.addItem(s,t,e.data);i&&i.setAttribute("data-init","true")}}))}this._buildSuggestions(e);this._resetHtmlState();this._fireEvents=true;this._config.onDataLoaded(e,this);this._selectElement.dispatchEvent(new CustomEvent("tags.loaded",{bubbles:true,detail:e}))}
/**
	 * Keep in mind that we can have the same value for multiple options
	 * @param {*} value
	 * @param {string} mode
	 * @param {number} counter
	 * @returns {HTMLOptionElement|null}
	 */_findOption(e=null,t="",s=0){const i=e===null?"":'[value="'+CSS.escape(e)+'"]';const n="option"+i+t;const l=this._selectElement.querySelectorAll(n);return l[s]||null}
/**
	 * Add item by value
	 * @param {string} value
	 * @param {object} data
	 * @return {HTMLOptionElement|null} The selected option or null
	 */setItem(e,t={}){let s=null;let i=this._findOption(e,":not([selected])");i&&(s=this.addItem(i.textContent,i.value,t));let n=this.getItem(e);if(n){const e=n[this._config.valueField];const i=n[this._config.labelField];s=this.addItem(i,e,t)}this._adjustWidth();this._checkMax();return s}
/**
	 * You might want to use canAdd before to ensure the item is valid
	 * @param {string} text
	 * @param {string} value
	 * @param {object} data
	 * @return {HTMLOptionElement} The created or selected option
	 */addItem(e,t=null,s={}){t||(t=e);this.isSingle()&&this.getSelectedValues().length&&this.removeLastItem(true);let i=this._findOption(t,":not([selected])");if(!i){i=ce("option");i.value=t;i.innerText=e;for(const[e,t]of Object.entries(s))i.dataset[e]=t;this._selectElement.appendChild(i);this._config.onCreateItem(i,this)}i&&(s=Object.assign({title:i.getAttribute("title")},s,i.dataset));i.setAttribute("selected","selected");i.selected=true;this._createBadge(e,t,s);this._fireEvents&&this._selectElement.dispatchEvent(new Event("change",{bubbles:true}));return i}_resetHtmlState(){const e=this._selectElement.innerHTML;this._selectElement.innerHTML="";this._selectElement.innerHTML=e;this._adjustWidth()}
/**
	 * @param {string} text
	 * @param {string} value
	 * @param {object} data
	 */_createBadge(e,s=null,i={}){const n=this._getBootstrapVersion()===5;const l=i.disabled&&parseBool(i.disabled);const o=this._config.allowClear&&!l;let a=this._config.allowHtml?e:this._config.sanitizer(e);
/**
		 * @type {HTMLSpanElement}
		 */let h=ce("span");let c=[t+"badge"];const d=this.isSingle()&&!this._config.singleBadge;if(!d){c.push("badge");let e=this._config.badgeStyle;i.badgeStyle&&(e=i.badgeStyle);i.badgeClass&&c.push(...i.badgeClass.split(" "));this._config.baseClass?c.push(...this._config.baseClass.split(" ")):c=n?[...c,"bg-"+e,"text-truncate"]:[...c,"badge-"+e];h.style.maxWidth="100%"}l&&c.push("disabled","opacity-50");const u=d?0:2;h.style.margin=u+"px 6px "+u+"px 0px";h.style.marginBlock=u+"px";h.style.marginInline="0px 6px";h.style.display="flex";h.style.alignItems="center";h.classList.add(...c);h.setAttribute(r,s);i.title&&h.setAttribute("title",i.title);if(o){const e=c.includes("text-dark")||d?"btn-close":"btn-close btn-close-white";let t="margin-inline: 0px 6px;";let s="left";this._config.clearEnd&&(s="right");s=="right"&&(t="margin-inline: 6px 0px;");const i=n?'<button type="button" style="font-size:0.65em;'+t+'" class="'+e+'" aria-label="'+this._config.clearLabel+'"></button>':'<button type="button" style="font-size:1em;'+t+'text-shadow:none;color:currentColor;transform:scale(1.2);float:none" class="close" aria-label="'+this._config.clearLabel+'"><span aria-hidden="true">&times;</span></button>';a=s=="left"?i+a:a+i}h.innerHTML=a;this._containerElement.insertBefore(h,this._searchInput);i.title&&g&&n&&g.getOrCreateInstance(h);o&&h.querySelector("button").addEventListener("click",(e=>{e.preventDefault();e.stopPropagation();this.isDisabled()||this._config.confirmClear(s,this).then((()=>{this.removeItem(s);document.activeElement.blur();this._adjustWidth()})).catch((()=>{}))}))}
/**
	 * @returns {HTMLDivElement}
	 */getHolder(){return this._holderElement}clear(){this.hideSuggestions();this.reset()}
/**
	 * Update data
	 * @param {Array<Suggestion|SuggestionGroup>|Object} src An array of items or a value:label object
	 */updateData(e){this.setData(e,false);this.reset()}
/**
	 * @param {string} value
	 * @param {Boolean} value
	 */removeItem(e,t=false){const s=CSS.escape(e);let i=this._containerElement.querySelectorAll("span["+r+'="'+s+'"]');if(!i.length)return;const n=i.length-1;const o=i[n];if(o){o.dataset.bsOriginalTitle&&g.getOrCreateInstance(o).dispose();o.remove()}let a=this._findOption(e,"[selected]",n);if(a){rmAttr(a,"selected");a.selected=false;this._fireEvents&&!t&&this._selectElement.dispatchEvent(new Event("change",{bubbles:true}))}if(this._searchInput.style.visibility=="hidden"&&!this.isMaxReached()){this._searchInput.style.visibility="visible";this._holderElement.classList.remove(l)}t||this._config.onClearItem(e,this)}}export{Tags as default};

