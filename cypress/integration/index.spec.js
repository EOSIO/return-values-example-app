describe('Return-Values-Example', () => {

  it('Sum Action', () => {
    cy.visit('http://localhost:8080')
    cy.get('input[name="first"]').clear().type(6)
    cy.get('input[name="second"]').clear().type(5)
    cy.get('.button').click()
    cy.wait(2000)
    cy.get('.result').should('have.text', '11')
  })

})