/**
 * This module is used to language translations.
 * The translations are saved in a json file in /src/app/assets/i18n directory
 * Docs: https://www.codeandweb.com/babeledit/tutorials/how-to-translate-your-angular7-app-with-ngx-translate
 */
import { HttpClient } from '@angular/common/http';
import { NgModule } from '@angular/core';
// import ngx-translate and the http loader
import { TranslateLoader, TranslateModule, TranslateService } from '@ngx-translate/core';
import { TranslateHttpLoader } from '@ngx-translate/http-loader';

// ngx-translate - required for AOT compilation
export function HttpLoaderFactory(http: HttpClient) {
  const baseHref = document.getElementsByTagName('base')[0].href;
  return new TranslateHttpLoader(http, `${baseHref}assets/i18n/`);
}

@NgModule({
  declarations: [],
  imports: [
    TranslateModule.forRoot({
      loader: {
        provide: TranslateLoader,
        useFactory: HttpLoaderFactory,
        deps: [HttpClient],
      },
    }),
  ],
  exports: [TranslateModule],
})
export class LanguageTranslationModule {
  constructor(private translate: TranslateService) {
    // Gets Default language from browser if available, otherwise set English ad default
    this.translate.addLangs([
      'en',
      'fr',
      'ur',
      'es',
      'it',
      'fa',
      'de',
      'zh-CHS',
    ]);
    this.translate.setDefaultLang('en');
    const browserLang = this.translate.getBrowserLang();
    this.translate.use(browserLang.match(/en|fr|ur|es|it|fa|de|zh-CHS/) ? browserLang : 'en');
  }
}
