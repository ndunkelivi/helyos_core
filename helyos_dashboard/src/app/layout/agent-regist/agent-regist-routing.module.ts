import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule, Routes } from '@angular/router';
import { AgentRegistComponent } from './agent-regist.component';

const routes: Routes = [
  {
    path: '',
    component: AgentRegistComponent,
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [
    RouterModule,
    FormsModule,
  ],
})
export class AgentRegistRoutingModule { }
