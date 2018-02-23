import { createSelector } from 'reselect';

const getAccountRelationship = (state, id) => state.getIn(['relationships', id], null);
const getAccountBase = (state, id) => state.getIn(['accounts', id], null);

export const makeGetSuggestedAccount = () => {
  return createSelector([getAccountBase, getAccountRelationship], (base, relationship) => {
    if (base === null) {
      return null;
    }

    return base.set('relationship', relationship);
  });
};
